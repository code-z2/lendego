// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.13;

interface ILiquidVault {
    function addNew(address token, address priceOracle, string memory pair) external; // restricted

    function deleteOne(uint256 index) external; // restricted

    function withdraw(address caller, uint256 assets, address receiver, uint256 choice) external; // restricted

    function deposit(address caller, uint256 assets, uint256 choice) external; // restricted

    function asset() external;
}
