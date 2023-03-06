// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface ITrustee {
    function isATrustee(address lender) external view returns (bool);

    function addTrustedAddress(address trustee) external;

    function removeTrustedAddress(address trustee) external;

    function getTrustedAddresses() external view returns (address[] memory);
}
