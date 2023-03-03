// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Shared.sol";
import "./extensions/TrustedLending.sol";

abstract contract Lending is TrustedLending, SharedStorage {
    event NewLoan(address indexed lender, address indexed stable, uint256 indexed asset, uint8 interestRate);
    event BurntPosition(address indexed burner, PartialNodeL lnode);
    event NewBorrowRequest(address indexed borrower, address indexed liquid, uint256 indexed assets, uint256 tenure);
    event BurntUnstablePosition(address indexed burner, PartialNodeB bnode);

    function createPosition(
        uint256 assets,
        uint8 choice,
        uint8 interest,
        bool approvalBased,
        // collateral percent greater than 125 is ignored.
        uint8 collateralPercent
    ) public {
        require(interest <= 15, "Interest rate cannot be more 15%");
        entrypoint.deposit(assets, msg.sender, choice, true);
        PartialNodeL memory _new = PartialNodeL({
            lender: msg.sender,
            choiceOfStable: choice,
            interestRate: interest,
            assets: assets,
            filled: false,
            acceptingRequests: true,
            approvalBased: approvalBased,
            minCollateralPercentage: collateralPercent
        });

        stablePool.push(_new);
        emit NewLoan(msg.sender, entrypoint.getSVaults()[choice], assets, interest);
    }

    function createUnstablePosition(
        uint8 choice,
        uint256 collateralIn_,
        uint256 maximumExpectedOutput_,
        uint8 tenure,
        uint8 interest
    ) public {
        require(tenure < 3, "invalid Tenure");
        require(interest <= 15, "Interest rate cannot be more 15%");

        address collateral_ = entrypoint.getLVaults()[choice].vault;
        uint8 vaultDecimals = IVault(collateral_).decimals();
        uint256 assets = getQuoteByExpectedOutput(maximumExpectedOutput_, choice, vaultDecimals, 125);

        require(collateralIn_ >= assets, "Minimum collateral threshold not satisfied");

        entrypoint.deposit(collateralIn_, msg.sender, choice, false);

        PartialNodeB memory _new = PartialNodeB({
            borrower: msg.sender,
            collateral: collateral_,
            collateralIn: collateralIn_,
            maximumExpectedOutput: maximumExpectedOutput_,
            tenure: acceptedTenures[tenure],
            indexOfCollateral: choice,
            maxPayableInterest: interest,
            restricted: false
        });
        liquidPool.push(_new);
        emit NewBorrowRequest(msg.sender, collateral_, assets, tenure);
    }

    function burnPosition(uint256 partialNodeLIdx) public {
        require(msg.sender == stablePool[partialNodeLIdx].lender, "invalid lender");
        require(!stablePool[partialNodeLIdx].filled, "cannot burn position");
        PartialNodeL memory temp = stablePool[partialNodeLIdx];
        _removeItemFromPool(partialNodeLIdx);
        entrypoint.withdraw(temp.assets, msg.sender, msg.sender, temp.choiceOfStable, true);
        emit BurntPosition(msg.sender, temp);
    }

    function burnUnstablePosition(uint256 partialNodeBIdx) public returns (bool success) {
        require(msg.sender == liquidPool[partialNodeBIdx].borrower, "Node does not exist");
        PartialNodeB memory temp = liquidPool[partialNodeBIdx];
        _removeUnstableItemFromPool(partialNodeBIdx);
        entrypoint.withdraw(temp.collateralIn, msg.sender, msg.sender, temp.indexOfCollateral, false);
        emit BurntUnstablePosition(msg.sender, temp);
        return true;
    }

    function _removeItemFromPool(uint256 index) internal {
        require(index < stablePool.length, "unable to remove");
        if (stablePool.length == 1) {
            delete stablePool[index];
        } else {
            stablePool[index] = stablePool[stablePool.length - 1];
            stablePool.pop();
        }
    }

    function _removeUnstableItemFromPool(uint256 index) internal {
        require(index < liquidPool.length, "unable to remove");
        if (liquidPool.length == 1) {
            delete liquidPool[index];
        } else {
            liquidPool[index] = liquidPool[liquidPool.length - 1];
            liquidPool.pop();
        }
    }

    function getQuoteByExpectedOutput(
        uint256 maximumExpectedOutput,
        uint8 choice,
        uint8 lDecimals,
        uint8 collateralPercent
    ) public view returns (uint256) {
        require(maximumExpectedOutput <= 100000000 ether, "cannot take more than 1m ether");
        uint8 _collateralPErcent = collateralPercent > 125 ? 125 : collateralPercent;
        // +/-(0.5%) offset from collateral%
        uint256 leastOutput = (maximumExpectedOutput * _collateralPErcent) / 100 + 1 gwei;
        // using the decimals of the default usd token
        uint8 sDecimals = IVault(entrypoint.getSVaults()[_defaultChoice]).decimals();
        return _scaleExpectedOutput(leastOutput, sDecimals, lDecimals, choice);
    }

    function _scaleExpectedOutput(
        uint256 output,
        uint8 sDecimals,
        uint8 lDecimals,
        uint8 choice
    ) internal view returns (uint256) {
        int256 latesPrice = oracle.getLatestPriceFromFeed(entrypoint.getLVaults()[choice].priceFeed);

        uint256 raw = (_scaleOutput(output, sDecimals, lDecimals) * 10**lDecimals) / uint256(latesPrice);

        return raw;
    }

    function _scaleOutput(
        uint256 output,
        uint8 sDecimals,
        uint8 expectedDecimals
    ) internal pure returns (uint256) {
        if (sDecimals < expectedDecimals) {
            return output * 10**uint256(expectedDecimals - sDecimals);
        } else if (sDecimals > expectedDecimals) {
            return output / 10**uint256(sDecimals - expectedDecimals);
        }
        return output;
    }
}
