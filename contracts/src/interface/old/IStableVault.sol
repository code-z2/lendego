// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.13;

interface IStablesVault {
    function asset() external;

    function totalAssets() external;

    function getshares(address shareHolder_) external view;

    function previewWithdraw(uint256 assets, uint256 choice) external;

    function previewRedeem(uint256 shares, uint256 choice) external;

    function deposit(address caller, uint256 assets, uint256 choice) external; // restricted

    function mint(address owner_, uint256 shares) external; // restricted

    function withdraw(address caller, uint256 assets, address receiver, address owner_, uint256 choice) external; //restricted

    function redeem(address caller, uint256 shares, address receiver, address owner_, uint256 choice) external; //restricted

    function temporaryPermit(uint256 choice, uint256 amount) external; // restricted

    function revokePermit(uint256 choice) external; // restricted
}
