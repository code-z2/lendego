// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title liquid token database for vLiquid
/// this contract is only for testing purposes
/// dont use in production
contract Liquids is Ownable {
    struct Tokens {
        address token;
        address priceOracle;
        string pair;
    }

    Tokens[] database;

    function addNew(address token, address priceOracle, string memory pair) public onlyOwner {
        database.push(Tokens(token, priceOracle, pair));
    }

    function getAll() external view returns (Tokens[] memory) {
        return database;
    }

    function getOne(uint256 index) external view returns (Tokens memory) {
        return database[index];
    }

    function deleteOne(uint256 index) public onlyOwner {
        // just delete, don't re-order, don't modify sequence
        delete database[index];
    }
}
