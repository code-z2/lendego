// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.17;

contract Diffuse {
    /**
     * @dev only devs
     * todo this function is meant to swap collateral back to defaultChoice from diffussion swap
     * todo moves the funds back to stable vault
     */
    function safeSwap(uint256 amount, uint256 selectedCollateral) external pure returns (bool) {
        // diffussion.swap(address(selectedCollateral), defaultChoice, amount);
        amount + selectedCollateral; // just to silent warnings
        return true;
    }
}
