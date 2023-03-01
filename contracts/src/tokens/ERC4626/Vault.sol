// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

/**
 * @title minimal erc4626 vault contract for multi-decimals vault coins (svToken/lvToken)
 * @author peter anyaogu
 * @notice implements a minimal version of EIP4626, uses multi-level access control for higher order strategy.
 * inspired by:
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC4626.sol
 * https://blog.logrocket.com/write-erc-4626-token-contract-yield-bearing-vaults
 * https://github.com/transmissions11/solmate/blob/main/src/mixins/ERC4626.sol
 */
contract Vault is ERC4626 {
    address private _entrypoint;

    modifier onlyEntrypoint() {
        require(msg.sender == _entrypoint, "caller must be entrypoint");
        _;
    }

    constructor(
        IERC20 asset,
        string memory name,
        string memory symbol,
        address entrypoint
    ) ERC4626(asset) ERC20(name, symbol) {
        _entrypoint = entrypoint;
    }

    function deposit(uint256 assets, address receiver) public override onlyEntrypoint returns (uint256) {
        require(assets <= maxDeposit(receiver), "ERC4626: deposit more than max");
        uint256 shares = previewDeposit(assets);
        _deposit(receiver, receiver, assets, shares);

        return shares;
    }

    function mint(address receiver, uint256 shares) public onlyEntrypoint {
        require(shares <= maxMint(receiver), "ERC4626: mint more than max");
        _mint(receiver, shares);
    }

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public override onlyEntrypoint returns (uint256) {
        require(assets <= maxWithdraw(owner), "ERC4626: withdraw more than max");

        uint256 shares = previewWithdraw(assets);
        _withdraw(receiver, receiver, owner, assets, shares);

        return shares;
    }

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public override onlyEntrypoint returns (uint256) {
        require(shares <= maxRedeem(owner), "ERC4626: redeem more than max");

        uint256 assets = previewRedeem(shares);
        _withdraw(receiver, receiver, owner, assets, shares);

        return assets;
    }

    function changeEntrypoint(address newEntrypoint) external onlyEntrypoint {
        _entrypoint = newEntrypoint;
    }

    function getEntrypoint() public view returns (address) {
        return _entrypoint;
    }

    /**
     * @notice grants temporary withdrawal permission from the controller.
     * @param spender the contract to be granted temp permit
     * @param value the amount of underlying expected to leave the vault
     */
    //? audit required
    function temporaryPermit(uint256 value, address spender) public onlyEntrypoint {
        SafeERC20.safeApprove(IERC20(asset()), spender, value);
    }
}
