// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IPersonalisation {
    function isBlacklisted(address user) external view returns (bool);

    function validator() external view returns (address);

    function incrementTTB(address user) external;
}
