// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Shared.sol";
import "./tokens/ERC4626/Entrypoint.sol";
import "./chainlink/PriceFeedConsumer.sol";

import "./interface/IPersonalisation.sol";

contract Lending is SharedStorage {
    using NodeHelpers for Pool;

    VaultsEntrypointV1 internal immutable _entrypoint;
    ArcmonPriceFeedConsumer internal immutable _oracle;

    IPersonalisation internal immutable _arcmon;

    event NewLoan(uint256 indexed index, address lender, uint8 choice, uint8 interest, uint256 assets, bool ab);
    event NewBorrowRequest(
        uint256 indexed index,
        address borrower,
        uint256 assets,
        uint256 amount,
        uint8 interest,
        uint8 choice,
        uint8 tenure
    );
    event ItemRemoved(uint256 index, address burner);
    event UnstableItemRemoved(uint256 index);

    error UnAuthorized();

    function createPosition(
        uint256 assets,
        uint8 choice,
        uint8 interest,
        bool approvalBased,
        uint8 collateralPercent
    ) public {
        if (interest > 15 || _arcmon.isBlacklisted(msg.sender)) revert UnAuthorized();
        _entrypoint.deposit(assets, msg.sender, choice, true);
        pools.create(assets, choice, interest, approvalBased, collateralPercent);
        emit NewLoan(pools.stablePool.length - 1, msg.sender, choice, interest, assets, approvalBased);
    }

    function createUnstablePosition(
        uint8 choice,
        uint256 collateralIn_,
        uint256 maximumExpectedOutput_,
        uint8 tenure,
        uint8 interest
    ) public {
        address collateral_ = _entrypoint.getLVaults()[choice].vault;
        uint8 vaultDecimals = IVault(collateral_).decimals();
        uint256 assets = _oracle.getQuoteByExpectedOutput(maximumExpectedOutput_, choice, vaultDecimals, 125);

        if (collateralIn_ < assets) revert UnAuthorized();
        _createUnstablePosition(
            msg.sender,
            collateral_,
            collateralIn_,
            choice,
            interest,
            tenure,
            maximumExpectedOutput_,
            false
        );
    }

    function createUnstablePositionPersonalised(
        address receiver,
        uint8 choice,
        uint256 collateralIn_,
        uint8 tenure,
        uint8 interest,
        uint8 factoredNomisPercent
    ) public {
        if (msg.sender != _arcmon.validator()) revert UnAuthorized();
        uint256 maximumExpectedOutput = 50 * 10 ** IVault(_entrypoint.getSVaults()[_defaultChoice]).decimals();

        address collateral_ = _entrypoint.getLVaults()[choice].vault;
        uint8 vaultDecimals = IVault(collateral_).decimals();

        uint256 assets = _oracle.getQuoteByExpectedOutput(
            maximumExpectedOutput,
            choice,
            vaultDecimals,
            factoredNomisPercent
        );
        if (collateralIn_ < assets) revert UnAuthorized();
        _createUnstablePosition(
            receiver,
            collateral_,
            collateralIn_,
            choice,
            interest,
            tenure,
            maximumExpectedOutput,
            true
        );
    }

    function _createUnstablePosition(
        address receiver,
        address _collateral,
        uint256 amount,
        uint8 choice,
        uint8 interest,
        uint8 tenure,
        uint256 expectedOutput,
        bool _personalised
    ) internal {
        if (tenure > 2 || interest > 15 || _arcmon.isBlacklisted(receiver)) revert UnAuthorized();
        pools.createUnstable(
            receiver,
            _collateral,
            amount,
            choice,
            interest,
            tenure,
            expectedOutput,
            _personalised,
            acceptedTenures
        );
        _entrypoint.deposit(amount, receiver, choice, false);
        emit NewBorrowRequest(pools.liquidPool.length - 1, receiver, amount, expectedOutput, interest, choice, tenure);
    }

    function burnPosition(uint256 partialNodeLIdx) public {
        PartialNodeL memory temp = pools.stablePool[partialNodeLIdx];
        if (msg.sender != temp.lender || temp.filled) revert UnAuthorized();

        delete pools.stablePool[partialNodeLIdx];
        _entrypoint.withdraw(temp.assets, msg.sender, msg.sender, temp.choiceOfStable, true);
        emit ItemRemoved(partialNodeLIdx, msg.sender);
    }

    function burnUnstablePosition(uint256 partialNodeBIdx) public {
        if (msg.sender != pools.liquidPool[partialNodeBIdx].borrower) revert UnAuthorized();

        PartialNodeB memory temp = _removeUnstableItemFromPool(partialNodeBIdx);
        _entrypoint.withdraw(temp.collateralIn, msg.sender, msg.sender, temp.indexOfCollateral, false);
    }

    function _removeUnstableItemFromPool(uint256 index) internal returns (PartialNodeB memory temp) {
        temp = pools.liquidPool[index];
        delete pools.liquidPool[index];
        emit UnstableItemRemoved(index);
    }

    constructor(address entrypoint, address arcmon) {
        _entrypoint = VaultsEntrypointV1(payable(entrypoint));
        _oracle = new ArcmonPriceFeedConsumer(entrypoint);
        _arcmon = IPersonalisation(arcmon);
    }
}
