// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.17;

interface ILend {
    function createPosition(uint256 assets, uint8 choice, uint8 interest) external;

    function burnPosition(uint256 partialNodeLIdx) external;

    function getAllLenders() external;

    function getStableVaultAddress() external;
}
