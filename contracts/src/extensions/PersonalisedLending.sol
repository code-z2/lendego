// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract Personalisation {
    address private _strategyAddress;
    address private _validator;

    mapping(address => uint256) internal ttb;

    mapping(address => bool) private blacklistedAddresses;

    error UnAuthorized(bytes reason);

    constructor(address validatorAddress, address strategyAddress) {
        _validator = validatorAddress;
        _strategyAddress = strategyAddress;
    }

    modifier onlyValidator() {
        if (msg.sender != _validator) revert UnAuthorized("not validator");
        _;
    }

    function updateValidator(address newValidator) public onlyValidator {
        _validator = newValidator;
    }

    function isBlacklisted() public view returns (bool) {
        return _isBlacklisted(msg.sender);
    }

    function isBlacklisted(address user) external view returns (bool) {
        return _isBlacklisted(user);
    }

    function reenact(address user) public onlyValidator {
        _reenact(user);
    }

    function validator() public view returns (address) {
        return _validator;
    }

    function incrementTTB(address user) external {
        if (msg.sender != _strategyAddress) revert UnAuthorized("not strategy");
        _incrementTTB(user);
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

    function setStrategy(address strategy) public onlyValidator {
        _strategyAddress = strategy;
    }
}
