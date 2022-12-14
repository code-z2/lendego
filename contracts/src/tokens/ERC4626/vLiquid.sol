// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.17;

import "../../lib/utils/Liquids.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// takes same approach as stablesVault
/// not a vault, it is only used to keep track/store of collaterals (liquid assets)
/// not implementing an ERC4626-like interface.
/// it serves similar usecase as StablesVault, Hence it is named LiquidVault
contract LiquidVault is Liquids, Ownable {
    // emits when a user deposits into the vault
    event Deposit(address caller, uint256 amount);
    // emits when a user widthraws from the vault
    event Withdraw(address caller, address receiver, uint256 amount);

    // keeps track of the user shares
    // owner => choice => balance
    mapping(address => mapping(uint256 => uint256)) private shareHolder;

    constructor(address editor) {
        // these roles are only applied in the liquids DB.
        // if the editor role is manipulated, the contracts may become
        // succeptible to oracle Manipulation
        _grantRole(DEFAULT_ADMIN_ROLE, editor);
        _grantRole(EDITOR_ROLE, editor);
    }

    function deposit(address caller, uint256 assets, uint256 choice) public onlyOwner returns (bool success) {
        // checks that the deposit value is higher than 0
        require(assets > 0, "Deposit is less than Zero");
        // the choice of liquid must be available
        require(choice <= database.length - 1, "Invalid choice of liquid");
        // transfers asset of choice from user to contract
        success = IERC20(database[choice].token).transferFrom(caller, address(this), assets);
        // checks the value of _assets the holder has
        if (success) {
            shareHolder[caller][choice] += assets;
            emit Deposit(caller, assets);
        }
    }

    function withdraw(
        address caller,
        uint256 assets,
        address receiver,
        uint256 choice
    ) public onlyOwner returns (bool success) {
        // if trying to withdraw, check theres is enough liquid.
        require(_totalAssets(choice) > assets, "not enough liquidity for selected liquid");
        require(assets <= shareHolder[caller][choice], "cannot widthraw more than shareholder has");
        // the choice of liquid must be available
        require(choice <= database.length - 1, "Invalid choice of liquid");

        // _withdraw handles rentrancy proof
        success = _withdraw(caller, receiver, assets, choice);
    }

    // return the list of all accepted liquid assets
    function asset() public view returns (Tokens[] memory) {
        return _getAll();
    }

    // returns the balance of a single asset
    function _totalAssets(uint256 choice) internal virtual returns (uint256) {
        return IERC20(database[choice].token).balanceOf(address(this));
    }

    function _withdraw(
        address caller,
        address receiver,
        uint256 assets,
        uint256 choice
    ) internal virtual returns (bool success) {
        // Conclusion: we need to do the transfer after the burn so that any reentrancy would happen after the
        shareHolder[caller][choice] -= assets;
        success = IERC20(database[choice].token).transfer(receiver, assets);

        emit Withdraw(caller, receiver, assets);
    }
}
