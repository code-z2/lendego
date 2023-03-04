// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/interfaces/IERC4626.sol";

interface IVault is IERC4626 {
    function deposit(uint256 assets, address receiver) external returns (uint256);

    function mint(address receiver, uint256 shares) external;

    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256);

    function redeem(uint256 shares, address receiver, address owner) external returns (uint256);

    function changeEntrypoint(address newEntrypoint) external;

    function getEntrypoint() external;

    function temporaryPermit(uint256 amount, address receiver) external returns (bool success);
}
