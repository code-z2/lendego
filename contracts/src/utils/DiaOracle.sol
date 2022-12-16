// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../../interface/IDIAOracle.sol";

contract DiaOracle is IDIAOracleV2 {
    function getValue(string memory pair) external pure returns (uint128, uint128) {
        pair;
        uint128 latestPrice = 12; // assuming the latest price is 12$
        uint128 other = 100; // i onestly wont use this
        return (latestPrice, other);
    }
}
