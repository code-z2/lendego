// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.13;

interface IBorrow {
    function createUnstablePosition(
        uint128 choice,
        uint256 collateralIn_,
        uint256 maximumExpectedOutput_,
        uint128 tenure_,
        uint8 interest
    ) external;

    function burnUnstablePosition(uint256 partialNodeLIdx) external;

    function getQuoteByExpectedOutput(uint256 maximumExpectedOutput_, uint128 choice) external;

    function getAllBorrowers() external;

    function getLiquidVaultAddress() external;
}
