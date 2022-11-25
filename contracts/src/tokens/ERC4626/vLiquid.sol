// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.17;

import "../../lib/utils/Liquids.sol";

contract LiquidVault is Liquids {
    // emits when a user deposits into the vault
    event Deposit(address caller, uint256 amount);
    // emits when a user widthraws from the vault
    event Withdraw(address caller, address receiver, address owner_, uint256 amount);

    // keeps track of the user shares
    // owner => choice => balance
    mapping(address => mapping(uint256 => uint256)) shareHolder;

    constructor(address editor) {
        // these roles are only applied in the liquids DB though.
        _grantRole(DEFAULT_ADMIN_ROLE, editor);
        _grantRole(EDITOR_ROLE, editor);
    }
}
