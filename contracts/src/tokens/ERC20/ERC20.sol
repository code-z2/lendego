// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// you can mint for yourself the Tokens used in the test implementation of EGO.sol
/// to test out out the lending/borrowing flow
// ATOM
contract Token is ERC20 {
    uint8 tokenDecimal = 18;

    constructor(string memory name, string memory symbol, uint8 _decimal) ERC20(name, symbol) {
        tokenDecimal = _decimal;
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function decimals() public view virtual override returns (uint8) {
        return tokenDecimal;
    }

    // yeah i know, you can mint for yourself for free yay! if you want!
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
