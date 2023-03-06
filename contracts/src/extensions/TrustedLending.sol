// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract TrustedLending {
    mapping(address => address[]) internal trustees;

    function isATrustee(address lender) public view returns (bool) {
        return _isATrustee(lender, msg.sender);
    }

    function addTrustedAddress(address trustee) public {
        trustees[msg.sender].push(trustee);
    }

    function removeTrustedAddress(address trustee) public {
        // copy to memory before looping
        address[] memory _trustees = trustees[msg.sender];
        for (uint256 i = 0; i < _trustees.length; i++) {
            if (_trustees[i] == trustee) {
                trustees[msg.sender][i] = _trustees[_trustees.length - 1];
                trustees[msg.sender].pop();
            }
        }
    }

    function getTrustedAddresses() public view returns (address[] memory) {
        return trustees[msg.sender];
    }

    function _isATrustee(address lender, address borrower) internal view returns (bool) {
        for (uint256 i = 0; i < trustees[lender].length; i++) {
            if (trustees[lender][i] == borrower) {
                return true;
            }
        }
        return false;
    }
}
