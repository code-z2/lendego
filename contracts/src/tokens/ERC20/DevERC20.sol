// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// you can mint for yourself the Tokens used in the test implementation of EGO.sol
/// to test out out the lending/borrowing flow
contract Atom is ERC20 {
    constructor() ERC20("Atom", "ATOM") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    // yeah i know, you can mint for yourself if you want!
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract WrappedETH is ERC20 {
    constructor() ERC20("WrappedETH", "WETH") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract Dia is ERC20 {
    constructor() ERC20("Dia", "DIA") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
