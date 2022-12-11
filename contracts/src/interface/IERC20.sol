// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20Plus is IERC20 {
    function decimals() external returns (uint8);
}
