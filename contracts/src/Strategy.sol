// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Lending.sol";
import "./utils/Diffuse.sol";
import "./interface/ITrustee.sol";

contract StrategyV1 is Lending {
    using NodeHelpers for Pool;

    Diffuse private immutable _diffuser;
    ITrustee private immutable _trustee;

    constructor(
        address entrypoint,
        address arcmon,
        address trustee,
        address[3] memory diffuserParams
    ) Lending(entrypoint, arcmon) {
        _diffuser = new Diffuse(diffuserParams[0], diffuserParams[1], diffuserParams[2]);
        _trustee = ITrustee(trustee);
    }

    event LoanTaken(uint256 indexed nodeId, bool isPending, uint256 lendId, PartialNodeL lend, PartialNodeB borrow);
    event LoanSettled(uint256 nodeId, address borrower, address lender, uint256 amount);
    event LoanExtended(uint256 nodeId);
    event NodeDeactivated(uint256 nodeId);
    event ErrorLogging(string reason);

    function approveNode(uint256 nodeId) public {
        Node memory node = pools.generalPool[nodeId];
        if (msg.sender != node.lend.lender || !node.isPending || !node.lend.approvalBased) revert UnAuthorized();

        pools.approve(nodeId);
        _permitAndTransfer(
            node.lend.assets,
            node.lend.choiceOfStable,
            node.borrow.borrower,
            _entrypoint.getSVaults()[node.lend.choiceOfStable],
            true
        );
    }

    function rejectNode(uint256 nodeId) public {
        Node memory node = pools.generalPool[nodeId];
        if (msg.sender != node.lend.lender || !node.isPending || !node.lend.approvalBased) revert UnAuthorized();

        pools.reject(nodeId);
        lockedStakes[node.lend.lender][node.lend.choiceOfStable] -= pools.generalPool[nodeId].lend.assets;
        _permitAndTransfer(
            node.borrow.collateralIn,
            node.borrow.indexOfCollateral,
            node.borrow.borrower,
            _entrypoint.getLVaults()[node.borrow.indexOfCollateral].vault,
            false
        );
        emit LoanSettled(nodeId, node.borrow.borrower, node.lend.lender, node.lend.assets);
    }

    function fillPosition(uint8 choice, uint256 assets, uint256 nodeIdL, uint8 tenure) public {
        PartialNodeL memory lend = pools.stablePool[nodeIdL];
        if (
            tenure > 2 ||
            nodeIdL >= pools.stablePool.length ||
            choice >= _entrypoint.getLVaults().length ||
            !lend.acceptingRequests ||
            _arcmon.isBlacklisted(msg.sender)
        ) revert UnAuthorized();

        if (lend.minCollateralPercentage < 125 && !_trustee.isATrustee(lend.lender)) revert UnAuthorized();

        address vault = _entrypoint.getLVaults()[choice].vault;
        address collateral = IVault(vault).asset();
        uint8 decimals = IVault(vault).decimals();
        uint256 minAsset = _oracle.getQuoteByExpectedOutput(
            lend.assets,
            choice,
            decimals,
            lend.minCollateralPercentage
        );

        if (assets < minAsset) revert UnAuthorized();

        lend.filled = true;
        _entrypoint.deposit(assets, msg.sender, choice, false);
        _handleNodeService(
            pools.fill(choice, assets, nodeIdL, tenure, collateral, lend.assets, lend.interestRate, acceptedTenures),
            lend,
            lend.approvalBased,
            nodeIdL
        );
    }

    function fillUnstablePosition(uint256 nodeIdB) public {
        PartialNodeB memory borrow = _removeUnstableItemFromPool(nodeIdB);
        if (borrow.restricted || _arcmon.isBlacklisted(msg.sender)) revert UnAuthorized();

        _entrypoint.deposit(borrow.maximumExpectedOutput, msg.sender, _defaultChoice, true);
        uint256 lendId = pools.stablePool.length;
        _handleNodeService(
            borrow,
            pools.fillUnstable(_defaultChoice, borrow.maxPayableInterest, borrow.maximumExpectedOutput),
            false,
            lendId
        );
    }

    function exitLenderFromPosition(uint256 nodeId) public {
        Node memory node = pools.generalPool[nodeId];
        if (msg.sender != node.lend.lender || !node.isOpen || pools.tenureExpired(nodeId)) revert UnAuthorized();
        _forcefullyExit(nodeId);
        emit LoanSettled(nodeId, node.borrow.borrower, node.lend.lender, node.lend.assets);
    }

    function exitBorrowerFromPosition(uint256 nodeId, address reciever) public {
        Node memory node = pools.generalPool[nodeId];
        if (msg.sender != node.borrow.borrower || !node.isOpen) revert UnAuthorized();

        address vaultAddress = _entrypoint.getSVaults()[node.lend.choiceOfStable];
        lockedStakes[node.lend.lender][node.lend.choiceOfStable] -= node.lend.assets;
        pools.generalPool[nodeId].isOpen = false;
        points[msg.sender]++;

        _transfer(IVault(vaultAddress).asset(), msg.sender, vaultAddress, pools.calcLoanPlusInterest(nodeId));
        _entrypoint.mint(node.lend.lender, pools.calcInterestOnly(nodeId), node.lend.choiceOfStable, true);
        _entrypoint.withdraw(node.borrow.collateralIn, reciever, msg.sender, node.borrow.indexOfCollateral, false);
        emit LoanSettled(nodeId, node.borrow.borrower, node.lend.lender, node.lend.assets);
    }

    function extendLoanDuration(uint256 nodeId) public {
        if (
            msg.sender != pools.generalPool[nodeId].borrow.borrower ||
            pools.tenureExpired(nodeId) ||
            !pools.generalPool[nodeId].isOpen ||
            pools.generalPool[nodeId].borrow.tenure % 30 != 0
        ) revert UnAuthorized();

        pools.extendDuration(nodeId);
        emit LoanExtended(nodeId);
    }

    function deactivatePartialNode(uint256 nodeIdL) public {
        if (msg.sender != pools.stablePool[nodeIdL].lender) revert UnAuthorized();
        pools.stablePool[nodeIdL].acceptingRequests = false;
        emit NodeDeactivated(nodeIdL);
    }

    function withdraw(uint256 assets, address receiver, uint8 choice) public {
        uint256 allowedWithdraw = IVault(_entrypoint.getSVaults()[choice]).balanceOf(msg.sender) -
            lockedStakes[msg.sender][choice];
        if (assets > allowedWithdraw) revert UnAuthorized();
        _entrypoint.withdraw(assets, receiver, msg.sender, choice, true);
    }

    function redeem(uint256 shares, address receiver, uint8 choice) public {
        uint256 allowedReedem = IVault(_entrypoint.getSVaults()[choice]).balanceOf(msg.sender) -
            lockedStakes[msg.sender][choice];
        if (shares > allowedReedem) revert UnAuthorized();
        _entrypoint.redeem(shares, receiver, msg.sender, choice, true);
    }

    function _handleNodeService(
        PartialNodeB memory borrow,
        PartialNodeL memory lend,
        bool pending,
        uint256 lendId
    ) internal {
        uint256 currentNodeCount = nodeCount;
        pools.mergeNode(borrow, lend, currentNodeCount, pending);
        nodeCount++;
        lockedStakes[lend.lender][lend.choiceOfStable] += lend.assets;

        if (!pending)
            _permitAndTransfer(
                lend.assets,
                lend.choiceOfStable,
                borrow.borrower,
                _entrypoint.getSVaults()[lend.choiceOfStable],
                true
            );
        emit LoanTaken(currentNodeCount, pending, lendId, lend, borrow);
    }

    function _permitAndTransfer(uint256 assets, uint8 choice, address to, address vaultAddress, bool stable) internal {
        _entrypoint.permit(assets, choice, stable);
        _transfer(IVault(vaultAddress).asset(), vaultAddress, to, assets);
    }

    function _transfer(address token, address from, address to, uint256 value) internal {
        SafeERC20.safeTransferFrom(IERC20(token), from, to, value);
    }

    function _forcefullyExit(uint256 nodeId) internal {
        Node memory node = pools.generalPool[nodeId];
        address liquidVault = _entrypoint.getLVaults()[node.borrow.indexOfCollateral].vault;
        address[] memory stableVaults = _entrypoint.getSVaults();

        uint256 debt = _oracle.scaleExpectedOutput(
            pools.calcLoanPlusInterest(nodeId),
            IVault(stableVaults[node.lend.choiceOfStable]).decimals(),
            IVault(liquidVault).decimals(),
            node.borrow.indexOfCollateral
        );

        pools.forcedExit(nodeId);
        lockedStakes[node.lend.lender][node.lend.choiceOfStable] -= node.lend.assets;
        _liquidate(debt, IERC20(node.borrow.collateral), stableVaults[_defaultChoice], liquidVault, node);
        emit NewBorrowRequest(
            pools.liquidPool.length - 1,
            node.borrow.borrower,
            node.borrow.collateralIn,
            0,
            node.borrow.maxPayableInterest,
            node.borrow.indexOfCollateral,
            node.borrow.tenure
        );
    }

    function _liquidate(uint256 amount, IERC20 tokenIn, address vaultIn, address vaultOut, Node memory node) internal {
        _arcmon.incrementTTB(node.borrow.borrower);
        points[node.borrow.borrower] = 0;
        uint256 interests = (amount * node.lend.interestRate) / 100;
        uint256 initialFunds = amount - interests;
        node.borrow.collateralIn -= initialFunds;

        _permitAndTransfer(amount, node.borrow.indexOfCollateral, address(_diffuser), vaultOut, false);
        _diffuser.diffuse(initialFunds, tokenIn, vaultIn);
        try _diffuser.diffuse(interests, tokenIn, vaultIn) {
            node.borrow.collateralIn -= interests;
            _entrypoint.mint(node.lend.lender, interests, node.lend.choiceOfStable, true);
        } catch Error(string memory reason) {
            emit ErrorLogging(reason);
        }
        _diffuser.refund(tokenIn, vaultOut);
    }
}
