// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Lending.sol";

contract StrategyV1 is Lending {
    constructor(address[5] memory initialUnderlyings, uint8 defaultChoice) SharedStorage(initialUnderlyings) {
        _defaultChoice = defaultChoice;
        nodeCount = 0;
    }

    event LoanTaken(address indexed by, address indexed from, uint256 indexed amount, uint128 tenure);
    event LoanSettled(address indexed by, address indexed lender, uint256 indexed amount, uint256 nodeId);
    event LoanExtended(uint256 indexed nodeId);
    event ErrorLogging(string reason);

    function approveNode(uint256 nodeId) public {
        require(msg.sender == generalPool[nodeId].lend.lender, "unknown caller");
        require(generalPool[nodeId].isPending, "position is not pending");
        require(generalPool[nodeId].lend.approvalBased, "node is not approvalBased");
        // approves a node;
        generalPool[nodeId].isPending = false;
        generalPool[nodeId].timeStamp = block.timestamp;
        PartialNodeL memory lend = generalPool[nodeId].lend;
        _permitAndTransfer(lend.assets,
            lend.choiceOfStable,
            generalPool[nodeId].borrow.borrower,
            entrypoint.getSVaults()[lend.choiceOfStable],
            true);
    }

    function rejectNode(uint256 nodeId) public {
        require(msg.sender == generalPool[nodeId].lend.lender, "unknown caller");
        require(generalPool[nodeId].isPending, "position is not pending");
        require(generalPool[nodeId].lend.approvalBased, "node is not approvalBased");
        // rejects a node;
        generalPool[nodeId].isOpen = false;
        generalPool[nodeId].isPending = false;
        lockedStakes[generalPool[nodeId].lend.lender] -= generalPool[nodeId].lend.assets;
        PartialNodeB memory borrow = generalPool[nodeId].borrow;
        _permitAndTransfer(borrow.collateralIn,
            borrow.indexOfCollateral,
            borrow.borrower,
            entrypoint.getLVaults()[borrow.indexOfCollateral].vault,
            false);
    }

    function fillPosition(
        uint8 choice,
        uint256 assets,
        uint256 nodeIdL,
        uint8 tenure
    ) public {
        PartialNodeL memory lender = stablePool[nodeIdL];
        require(tenure < 3, "unsurpported tenure");
        require(nodeIdL < stablePool.length, "partial node does not exist");
        require(choice < entrypoint.getLVaults().length, "vault does not exist");
        require(lender.acceptingRequests, "lender not accepting requests");

        if (lender.minCollateralPercentage < 125){
            require(_isATrustee(lender.lender, msg.sender), "not allowed");
        }

        address vault = entrypoint.getLVaults()[choice].vault;
        address collateral = IVault(vault).asset();
        uint8 decimals = IVault(vault).decimals();

        uint256 minAsset = getQuoteByExpectedOutput(lender.assets, choice, decimals, lender.minCollateralPercentage);

        require(assets >= minAsset, "Minimum collateral threshold not satisfied");

        entrypoint.deposit(assets, msg.sender, choice, false);

        PartialNodeB memory borrower = PartialNodeB({
            borrower: msg.sender,
            collateral: collateral,
            collateralIn: assets,
            maximumExpectedOutput: lender.assets,
            tenure: acceptedTenures[tenure],
            indexOfCollateral: choice,
            maxPayableInterest: lender.interestRate,
            restricted: false
        });

        // sets the node in memory to filled
        lender.filled = true;

        _handleNodeService(borrower, lender, lender.approvalBased);
        // sets the actual node to filled
        stablePool[nodeIdL].filled = true;
        emit LoanTaken(msg.sender, lender.lender, lender.assets, acceptedTenures[tenure]);
    }

    function fillUnstablePosition(uint256 nodeIdB) public {
        require(!liquidPool[nodeIdB].restricted, "you can't fill this node");

        entrypoint.deposit(liquidPool[nodeIdB].maximumExpectedOutput, msg.sender, _defaultChoice, true);

        PartialNodeL memory lender = PartialNodeL({
            lender: msg.sender,
            choiceOfStable: _defaultChoice,
            interestRate: liquidPool[nodeIdB].maxPayableInterest,
            assets: liquidPool[nodeIdB].maximumExpectedOutput,
            filled: true,
            acceptingRequests: true,
            approvalBased: false,
            minCollateralPercentage: 125
        });

        stablePool.push(lender);
        _handleNodeService(liquidPool[nodeIdB], lender, false);

        _removeUnstableItemFromPool(nodeIdB);
        emit LoanTaken(
            liquidPool[nodeIdB].borrower,
            msg.sender,
            liquidPool[nodeIdB].maximumExpectedOutput,
            liquidPool[nodeIdB].tenure
        );
    }

    function exitLenderFromPosition(uint256 nodeId) public {
        require(msg.sender == generalPool[nodeId].lend.lender, "unknown caller");
        require(generalPool[nodeId].isOpen, "position has been closed");
        require(_hasTenureExpired(generalPool[nodeId]), "loan is still active");
        // ? audit required
        _forcefullyExit(nodeId);

        emit LoanSettled(
            generalPool[nodeId].borrow.borrower,
            generalPool[nodeId].lend.lender,
            generalPool[nodeId].lend.assets,
            nodeId
        );
    }

    function exitBorrowerFromPosition(uint256 nodeId, address reciever) public {
        require(msg.sender == generalPool[nodeId].borrow.borrower, "unknown caller");
        require(generalPool[nodeId].isOpen, "position has been closed");

        Node memory node = generalPool[nodeId];
        address vaultAddress = entrypoint.getSVaults()[node.lend.choiceOfStable];

        _transfer(IVault(vaultAddress).asset(), msg.sender, vaultAddress, calcLoanPlusInterest(nodeId));

        lockedStakes[node.lend.lender] -= node.lend.assets;
        entrypoint.mint(node.lend.lender, calcInterestOnly(nodeId), node.lend.choiceOfStable, true);
        generalPool[nodeId].isOpen = false;
        points[msg.sender]++;
        entrypoint.withdraw(node.borrow.collateralIn, reciever, msg.sender, node.borrow.indexOfCollateral, false);
        emit LoanSettled(node.borrow.borrower, node.lend.lender, node.lend.assets, nodeId);
    }

    function extendLoanDuration(uint256 nodeId) public {
        require(msg.sender == generalPool[nodeId].borrow.borrower, "invalid caller");
        require(!_hasTenureExpired(generalPool[nodeId]), "tenure cannot be extended");
        require(generalPool[nodeId].isOpen, "position has been closed");
        require(generalPool[nodeId].borrow.tenure % 30 == 0, "tenure can only be extended once");

        generalPool[nodeId].borrow.tenure += 15;

        uint8 oldInterst = generalPool[nodeId].lend.interestRate;
        uint8 newInterest = oldInterst / uint8(generalPool[nodeId].borrow.tenure / 15) + oldInterst;

        (newInterest > 15)
            ? generalPool[nodeId].lend.interestRate = 15
            : generalPool[nodeId].lend.interestRate = newInterest;
        emit LoanExtended(nodeId);
    }

    function calcLoanPlusInterest(uint256 nodeId) public view returns (uint256) {
        return generalPool[nodeId].lend.assets + calcInterestOnly(nodeId);
    }

    function calcInterestOnly(uint256 nodeId) public view returns (uint256) {
        return (generalPool[nodeId].lend.assets * generalPool[nodeId].lend.interestRate) / 100;
    }

    function deactivatePartialNode(uint256 nodeIdL) public {
        require(msg.sender == stablePool[nodeIdL].lender, "failed to deactivate");
        stablePool[nodeIdL].acceptingRequests = false;
    }

    function withdraw(
        uint256 assets,
        address receiver,
        uint8 choice
    ) public {
        uint256 allowedWithdraw = IVault(entrypoint.getSVaults()[choice]).previewWithdraw(assets) -
            lockedStakes[msg.sender];
        require(assets < allowedWithdraw, "cannot withdraw more than allowed");
        entrypoint.withdraw(assets, receiver, msg.sender, choice, true);
    }

    function redeem(
        uint256 shares,
        address receiver,
        uint8 choice
    ) public {
        uint256 allowedReedem = IVault(entrypoint.getSVaults()[choice]).previewRedeem(shares) -
            lockedStakes[msg.sender];

        require(shares < allowedReedem, "cannot redeem more than allowed");
        entrypoint.redeem(shares, receiver, msg.sender, choice, true);
    }

    function _handleNodeService(
        PartialNodeB memory borrow,
        PartialNodeL memory lend,
        bool pending
    ) internal {
        Node memory _new = Node({
            nodeId: nodeCount,
            // don't start counting if it's approvalBased
            timeStamp: pending ? 0: block.timestamp,
            isOpen: true,
            isPending: pending,
            lend: lend,
            borrow: borrow
        });

        generalPool[nodeCount] = _new;
        nodeCount++;
        lockedStakes[lend.lender] += lend.assets;

        if (!pending)
            _permitAndTransfer(
                lend.assets,
                lend.choiceOfStable,
                borrow.borrower,
                entrypoint.getSVaults()[lend.choiceOfStable],
                true
            );
    }

    function _permitAndTransfer(
        uint256 assets,
        uint8 choice,
        address to,
        address vaultAddress,
        bool stable
    ) internal {
        // entrypoint permits strategy to withdraw from a vault.
        entrypoint.permit(assets, choice, stable);
        _transfer(IVault(vaultAddress).asset(), vaultAddress, to, assets);
    }

    function _transfer(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        SafeERC20.safeTransferFrom(IERC20(token), from, to, value);
    }

    function _hasTenureExpired(Node memory node) internal view returns (bool) {
        return block.timestamp > node.timeStamp + node.borrow.tenure * 1 days;
    }

    function _forcefullyExit(uint256 nodeId) internal {
        // exit without notice
        Node memory node = generalPool[nodeId];
        address liquidVault = entrypoint.getLVaults()[node.borrow.indexOfCollateral].vault;
        address[] memory stableVaults = entrypoint.getSVaults();

        // converts lenders funds to borrowers collateral equivalent
        uint256 debt = _scaleExpectedOutput(
            calcLoanPlusInterest(nodeId),
            IVault(stableVaults[node.lend.choiceOfStable]).decimals(),
            IVault(liquidVault).decimals(),
            node.borrow.indexOfCollateral
        );

        _liquidate(debt, IERC20(node.borrow.collateral), stableVaults[_defaultChoice], liquidVault, node);

        node.borrow.restricted = true;
        node.isOpen = false;
        lockedStakes[node.lend.lender] -= node.lend.assets;
        liquidPool.push(node.borrow);
        generalPool[nodeId] = node;
    }

    function _liquidate(
        uint256 amount,
        IERC20 tokenIn,
        address vaultIn,
        address vaultOut,
        Node memory node
    ) internal {
        uint256 interests = (amount * node.lend.interestRate) / 100;
        uint256 initialFunds = amount - interests;

        // transfer collateral to the diffuse contract
        _permitAndTransfer(amount, node.borrow.indexOfCollateral, address(diffuser), vaultOut, false);

        // diffuse the main amount first
        diffuser.diffuse(initialFunds, tokenIn, vaultIn);
        node.borrow.collateralIn -= initialFunds;

        // diffuse the interest
        try diffuser.diffuse(interests, tokenIn, vaultIn) {
            entrypoint.mint(node.lend.lender, interests, node.lend.choiceOfStable, true);
            node.borrow.collateralIn -= interests;
        } catch Error(string memory reason) {
            emit ErrorLogging(reason);
        }

        // refund excess tokens back to vault
        diffuser.refund(tokenIn, vaultOut);
    }
}
