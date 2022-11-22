// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, 50 * 10 ** decimals());
    }
}
