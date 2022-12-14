// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// you can mint for yourself the Tokens used in the test implementation of EGO.sol
/// to test out out the lending/borrowing flow
// ATOM
contract Atom is ERC20 {
    constructor() ERC20("Atom", "ATOM") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    // yeah i know, you can mint for yourself for free yay! if you want!
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

// WETH
contract WrappedETH is ERC20 {
    constructor() ERC20("Wrapped ETH", "WETH") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

// WEVMOS
contract WrappedEvmos is ERC20 {
    constructor() ERC20("Wrapped Evmos", "WEVMOS") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

// DIA
contract Dia is ERC20 {
    constructor() ERC20("Dia", "DIA") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

// USDC
contract USDC is ERC20 {
    constructor() ERC20("USDC", "USDC") {
        _mint(msg.sender, 100000 * 10 ** decimals());
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

// USDT
contract USDT is ERC20 {
    constructor() ERC20("USDT", "USDT") {
        _mint(msg.sender, 100000 * 10 ** decimals());
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

// DAI
contract Dai is ERC20 {
    constructor() ERC20("Dai", "DAI") {
        _mint(msg.sender, 100000 * 10 ** decimals());
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

// BUSD
contract BUSD is ERC20 {
    constructor() ERC20("BUSD", "BUSD") {
        _mint(msg.sender, 100000 * 10 ** decimals());
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

// FRAX
contract FraxShare is ERC20 {
    constructor() ERC20("Fraxshare", "FRAX") {
        _mint(msg.sender, 100000 * 10 ** decimals());
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
