// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract PersonalisedLending {
    address private _validator;
    mapping(address => uint256) internal ttb;

    mapping(address => bool) private blacklistedAddresses;

    constructor(address validator) {
        _validator = validator;
    }

    modifier onlyValidator() {
        require(msg.sender == _validator, "not the validator");
        _;
    }

    function updateValidator(address newValidator) public onlyValidator {
        _validator = newValidator;
    }

    function isBlacklisted() public view returns (bool) {
        return _isBlacklisted(msg.sender);
    }

    function reenact(address user) public onlyValidator {
        _reenact(user);
    }

    function _incrementTTB(address user) internal {
        if (ttb[user] >= 9) {
            ttb[user]++;
            _blacklist(user);
        } else {
            ttb[user]++;
        }
    }

    function _blacklist(address user) internal {
        blacklistedAddresses[user] = true;
    }

    function _isBlacklisted(address user) internal view returns (bool) {
        return blacklistedAddresses[user];
    }

    // even after re-enactment, you will get blacklisted once liquidated again
    function _reenact(address user) internal {
        if (ttb[user] <= 20) {
            blacklistedAddresses[user] = false;
        } else revert("max number of reenactments reached");
    }
}
