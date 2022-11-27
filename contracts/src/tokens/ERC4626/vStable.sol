// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

/// @title minimal multi-token vault contract for stable coins (svToken)
/// @author peteruche21
/// note this is minimal and does not implement all methods in EIP4626
/// since it is a mutli-token vault, methods and abis deviate from standard EIP4626
/// withdrawing/depositing/redeeming/minting directly from this stable vault is not permitted
/// as can only be called by the vault deployer: my bad :(.
/// please see interface/IEgo for yeild flows
/// inspired by:
/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC4626.sol
/// https://blog.logrocket.com/write-erc-4626-token-contract-yield-bearing-vaults/
/// https://github.com/transmissions11/solmate/blob/main/src/mixins/ERC4626.sol
contract StablesVault is ERC20, Ownable {
    using Math for uint256;
    // array of five stable coins
    address[5] _assets; // IERC20[5] works but tests disagrees

    // emits when a user deposits into the vault
    event Deposit(address caller, uint256 amount);
    // emits when a user widthraws from the vault
    event Withdraw(address caller, address receiver, address owner_, uint256 amount, uint256 shares);

    // keeps track of the user shares
    mapping(address => uint256) shareHolder;

    // sets the erc20 stables.
    constructor(address[5] memory assets, string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _assets = assets;
    }

    // return the list of addresses for assets
    function asset() public virtual returns (address[5] memory) {
        return _assets;
    }

    // return a list of balances for all assets
    function totalAssets() public returns (uint256[5] memory) {
        // i wish there was promise.all[] lol;
        uint256[5] memory balances;
        for (uint256 i = 0; i < _assets.length; i++) {
            balances[i] = _totalAssets(i);
        }
        return balances;
    }

    function getshares(address shareHolder_) external view returns (uint256) {
        return shareHolder[shareHolder_];
    }

    function previewWithdraw(uint256 assets, uint256 choice) public virtual returns (uint256) {
        uint256 supply = totalSupply();
        return (assets == 0 || supply == 0) ? assets : assets.mulDiv(supply, _totalAssets(choice), Math.Rounding.Up);
    }

    function previewRedeem(uint256 shares, uint256 choice) public virtual returns (uint256) {
        uint256 supply = totalSupply();
        return (supply == 0) ? shares : shares.mulDiv(_totalAssets(choice), supply, Math.Rounding.Down);
    }

    /** deposit assets of choice to the vault
     * @param caller: the address of who is depositing,
     * in the widthraw flow, only the message.sender is allowed since you can withdraw from vault directly
     */
    function deposit(address caller, uint256 assets, uint256 choice) public onlyOwner returns (bool success) {
        // checks that the deposit value is higher than 0
        require(assets > 0, "Deposit is less than Zero");
        // the choice of stable must be available
        require(choice >= 0 && choice <= _assets.length - 1, "Invalid choice of Stable");
        // transfers asset of choice from user to contract
        success = IERC20(_assets[choice]).transferFrom(caller, address(this), assets);
        // checks the value of _assets the holder has
        if (success) {
            shareHolder[caller] += assets;
            // mints to the receiver reciept(shares)
            _mint(caller, assets);
            emit Deposit(caller, assets);
        }
    }

    /** @notice The Strategy
     * when a borrower deposits back his loan
     * the accrued interest will be minted to the lender in form of shares
     * lender can then redeem these shares for actual stables
     * */
    function mint(address owner_, uint256 shares) public onlyOwner {
        // you cant recieve additional shares if you have widthrawn your funds
        require(shareHolder[owner_] >= shares, "owner must have assets equivalent or more than shares");
        _mint(owner_, shares);
    }

    /**
     * @notice - allows a participant to withdraw any other asset other than the one initially deposited
     * Takes in assets and calculates the amount of shares eligible.
     * only the explicit assets deposits can be withdrawn
     * @param assets - the amount of stable assets to withdraw
     * @param receiver - allows the withdrawer to withdraw to an external address
     * @param owner_ - owner_ of the share. #case : can allow a user with vToken allowance to address to withdraw the stables
     * @param choice - the choice of stable to widthraw
     * choice of stable allows a shareholder to deposit USDT and withdraw BUSD if liquidity is sufficient for the latter
     * @return uint256 - shares redeemed
     */
    function withdraw(
        address caller,
        uint256 assets,
        address receiver,
        address owner_,
        uint256 choice
    ) public onlyOwner returns (uint256) {
        // if trying to withdraw another stable, check theres is enough stable.
        require(_totalAssets(choice) > assets, "not enough liquidity for selected stable");
        require(assets <= shareHolder[owner_], "cannot widthraw more than shareholder has");
        // the choice of stable must be available
        require(choice >= 0 && choice <= _assets.length - 1, "Invalid choice of Stable");

        uint256 shares = previewWithdraw(assets, choice);
        // _withdraw handles rentrancy proof
        bool success = _withdraw(caller, receiver, owner_, assets, shares, choice);

        if (success) shareHolder[owner_] -= assets;

        return shares;
    }

    /**
     * @notice - Takes in shares instead of assets and withdraws stables corresponding
     * to the amount of shares eligible for the user
     * in IEgo flow, once a user refunds his loan, the loan + interest is put into this contract and lender is minted more shares.
     * shares minted to lender can only be redeemed and cannot be directly withdrawn because of shareHolder limitations.
     * @param shares - the amount of vToken the user is seeking to redeem
     * @param receiver - the address of the person that wil recieve this shares
     * @param owner_ - the shareHolder: in this case the owner_ of the shares
     * @param choice - the choice of stable to redeem.
     * @return uint256 - assets redeemed.
     */
    function redeem(
        address caller,
        uint256 shares,
        address receiver,
        address owner_,
        uint256 choice
    ) public onlyOwner returns (uint256) {
        // you can only redeem shares for stables if the shares are less than the vToken balance of the shareHolder
        require(shares <= balanceOf(owner_), "ERC4626: redeem more than max");
        // the choice of stable must be available
        require(choice >= 0 && choice <= _assets.length - 1, "Invalid choice of Stable");

        uint256 assets = previewRedeem(shares, choice);
        _withdraw(caller, receiver, owner_, assets, shares, choice);

        return assets;
    }

    // returns the address of a single asset
    function _asset(uint256 choice) internal virtual returns (address) {
        return _assets[choice];
    }

    // returns the balance of a siingle asset
    function _totalAssets(uint256 choice) internal virtual returns (uint256) {
        return IERC20(_assets[choice]).balanceOf(address(this));
    }

    function _withdraw(
        address caller,
        address receiver,
        address owner_,
        uint256 assets,
        uint256 shares,
        uint256 choice
    ) internal virtual returns (bool success) {
        // check if the caller has sufficient rights to access the shares
        // gives allowance to widthraw the stables
        if (caller != owner_) {
            _spendAllowance(owner_, caller, shares);
        }

        // Conclusion: we need to do the transfer after the burn so that any reentrancy would happen after the
        // shares are burned and after the assets are transferred, which is a valid state.

        _burn(owner_, shares);
        bool _success = IERC20(_assets[choice]).transfer(receiver, assets);

        emit Withdraw(caller, receiver, owner_, assets, shares);
        success = _success;
    }
}

// todo - implementing a full EIP4626-like vault for multi-tokens (stables)
