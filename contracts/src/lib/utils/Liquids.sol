// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title liquid token database for vLiquid
/// this contract is only for testing purposes
/// dont use in production
contract Liquids is AccessControl {
    // Create a new role identifier for the minter role
    bytes32 public constant EDITOR_ROLE = keccak256("EDITOR_ROLE");
    struct Tokens {
        address token;
        address priceOracle;
        string pair;
    }

    Tokens[] internal database;

    function addNew(address token, address priceOracle, string memory pair) public onlyRole(EDITOR_ROLE) {
        database.push(Tokens(token, priceOracle, pair));
    }

    function deleteOne(uint256 index) public onlyRole(EDITOR_ROLE) {
        // just delete, don't re-order, don't modify sequence
        delete database[index];
    }

    function _getAll() internal view returns (Tokens[] memory) {
        return database;
    }

    function _getOne(uint256 index) internal view returns (Tokens memory) {
        return database[index];
    }
}
