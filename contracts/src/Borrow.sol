// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.17;

import "./tokens/ERC4626/vLiquid.sol";
import "./interface/IDIAOracle.sol";

contract Borrow {
    LiquidVault immutable liquidV;
    uint128[3] acceptedTenures = [30, 60, 90]; // days
    struct PartialNodeB {
        // borrowers details
        address borrower;
        address collateral;
        uint256 collateralIn;
        uint256 maximumExpectedOutput; // usd
        uint128 tenure;
        uint128 indexOfCollateral;
        uint8 maxPayableInterest;
        bool restricted;
    }

    // pool of borrowers
    PartialNodeB[] bPool;

    constructor() {
        liquidV = new LiquidVault(msg.sender);
    }

    event NewBorrowRequest(address borrower, address liquid, uint256 assets, uint256 tenure);

    function createUnstablePosition(
        uint128 choice,
        uint256 collateralIn_,
        uint256 maximumExpectedOutput_,
        uint128 tenure_,
        uint8 interest
    ) public {
        require(acceptedTenures[tenure_] != 0, "Tenure: please choose a valid loan duration");
        require(interest <= 15, "Interest reate cannot be more 15%");
        address collateral_ = liquidV.asset()[choice].token;
        // calculte 125% of maximumExpectedOutput in usd
        uint256 assets = getQuoteByExpectedOutput(maximumExpectedOutput_, choice);
        require(collateralIn_ >= assets, "Minimum collateral threshold not satisfied");
        // deposit into the vault
        bool success = liquidV.deposit(msg.sender, collateralIn_, choice);
        // create new position
        PartialNodeB memory new_ = PartialNodeB({
            borrower: msg.sender,
            collateral: collateral_,
            collateralIn: collateralIn_,
            maximumExpectedOutput: maximumExpectedOutput_,
            tenure: acceptedTenures[tenure_],
            indexOfCollateral: choice,
            maxPayableInterest: interest,
            restricted: false
        });
        // broadcast new position
        success ? bPool.push(new_) : revert("deposit failed");
        emit NewBorrowRequest(msg.sender, collateral_, assets, tenure_);
    }

    function burnUnstablePosition(uint256 partialNodeLIdx) public {
        // requires only msg.sender == partialNodeL.borrower
        require(
            msg.sender == bPool[partialNodeLIdx].borrower,
            "Borrower: you are not the borrower that created this node, or node does not exist"
        );
        // delete the partialnode
        _removeUnstableItemFromPool(partialNodeLIdx);
        // transfer liquid from vault to borrower
        liquidV.withdraw(
            msg.sender,
            bPool[partialNodeLIdx].collateralIn,
            msg.sender,
            bPool[partialNodeLIdx].indexOfCollateral
        );
    }

    function getQuoteByExpectedOutput(uint256 maximumExpectedOutput_, uint128 choice) public returns (uint256) {
        // perform dia oracle operation
        (uint128 latestPrice, ) = IDIAOracleV2(liquidV.asset()[choice].priceOracle).getValue(
            liquidV.asset()[choice].pair
        );
        // calculate maximumExpectedOutput_ + 5 of the price; where 5 is offset
        uint256 toBeDebited = (maximumExpectedOutput_ + 5) / latestPrice;
        // return 125%
        return (toBeDebited / 4) + toBeDebited;
    }

    function _removeUnstableItemFromPool(uint256 index) internal {
        require(bPool.length > 0 && bPool.length <= index, "unable to remove");
        bPool[index] = bPool[bPool.length - 1];
        bPool.pop();
    }
}
