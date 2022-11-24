// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.17;

contract Borrow {
    uint256[3] acceptedTenures = [30, 60, 90]; // days
    struct PartialNodeB {
        // borrowers details
        address borrower;
        address collateral;
        uint256 collateralIn;
        uint256 maximumExpectedOutput; // usd
        uint256 tenure;
    }

    // pool of borrowers
    PartialNodeB[] bPool;

    constructor() {}

    function _removeUnstableItemFromPool(uint256 index) internal {
        require(bPool.length > 0 && bPool.length <= index, "unable to remove");
        bPool[index] = bPool[bPool.length - 1];
        bPool.pop();
    }
}
