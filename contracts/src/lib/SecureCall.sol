// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

library SecureCall {
    function lowLevelCall(
        bytes memory _payload,
        address _to,
        uint256 _value
    ) private returns (bool) {
        (bool success, bytes memory returnData) = address(_to).call(_payload);
        if (success) {
            uint256 decoded = abi.decode(returnData, (uint256));
            return decoded >= _value ? true : false;
        }
        return false;
    }
}