// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Vault.sol";
import "../../interface/IVault.sol";
import {EntrypointVars, Tokens} from "../../lib/Structs.sol";

/**
 * @title Entrypoint contract to alchemoney vaults
 * @author peter anyaogu
 * @notice mimnimal implementation contract for ERC4626 vaults entrypoint.
 * this contract routes interaction to the respective vaults without caompromising vault security.
 * this Entrypoint implements the security layer for vaults.
 */
contract VaultsEntrypointV1 {
    EntrypointVars private store;

    modifier onlyEditor() {
        require(msg.sender == store._editor, "caller is not editor!");
        _;
    }

    modifier onlyStrategy() {
        require(msg.sender == store._strategy, "caller is not editor!");
        _;
    }

    constructor(
        address[5] memory underlyings,
        address strategy,
        address editor
    ) {
        store._editor = editor;
        store._strategy = strategy;
        address self = address(this);

        store._stables[0] = address(new Vault(IERC20(underlyings[0]), "alchemy DAI", "svDAI", self));
        store._stables[1] = address(new Vault(IERC20(underlyings[1]), "alchemy USDC", "svUSDC", self));
        store._stables[2] = address(new Vault(IERC20(underlyings[2]), "alchemy USDT", "svUSDT", self));
        store._liquids[0].vault = address(new Vault(IERC20(underlyings[3]), "alchemy FTM", "lvFTM", self));
        store._liquids[1].vault = address(new Vault(IERC20(underlyings[4]), "alchemy WETH", "lvWETH", self));
    }

    function getSVaults() public view returns (address[] memory) {
        return store._stables;
    }

    function getLVaults() public view returns (Tokens[] memory) {
        return store._liquids;
    }

    function addNewSVault(address newVaultAddress) public onlyEditor {
        store._stables.push(newVaultAddress);
    }

    function addNewLVault(address newVaultAddress, address priceFeed) public onlyEditor {
        store._liquids.push(Tokens(newVaultAddress, priceFeed));
    }

    function updateSVaultAtIndex(address updatedVaultAddress, uint256 index) public onlyEditor {
        store._stables[index] = updatedVaultAddress;
    }

    function updateLVaultAtIndex(address updatedVaultAddress, uint256 index) public onlyEditor {
        store._liquids[index].vault = updatedVaultAddress;
    }

    function setPriceFeedForVault(uint256 index, address priceFeed) public onlyEditor {
        store._liquids[index].priceFeed = priceFeed;
    }

    function deleteSVaultAtIndex(uint256 index) public onlyEditor {
        require(index < store._stables.length, "unable to remove");
        if (store._stables.length == 1) {
            delete store._stables[index];
        } else {
            store._stables[index] = store._stables[store._stables.length - 1];
            store._stables.pop();
        }
    }

    function deleteLVaultAtIndex(uint256 index) public onlyEditor {
        require(index < store._liquids.length, "unable to remove");
        if (store._liquids.length == 1) {
            delete store._liquids[index];
        } else {
            store._liquids[index] = store._liquids[store._liquids.length - 1];
            store._liquids.pop();
        }
    }

    function changeEditor(address newEditor) public onlyEditor {
        store._editor = newEditor;
    }

    // beggining of strategy calls
    function deposit(
        uint256 assets,
        address receiver,
        uint8 choice,
        bool stable
    ) external onlyStrategy {
        IVault(stable ? store._stables[choice] : store._liquids[choice].vault).deposit(assets, receiver);
    }

    function mint(
        address receiver,
        uint256 shares,
        uint8 choice,
        bool stable
    ) external onlyStrategy {
        IVault(stable ? store._stables[choice] : store._liquids[choice].vault).mint(receiver, shares);
    }

    function withdraw(
        uint256 assets,
        address receiver,
        address owner,
        uint8 choice,
        bool stable
    ) external onlyStrategy {
        IVault(stable ? store._stables[choice] : store._liquids[choice].vault).withdraw(assets, receiver, owner);
    }

    function redeem(
        uint256 shares,
        address receiver,
        address owner,
        uint8 choice,
        bool stable
    ) external onlyStrategy {
        IVault(stable ? store._stables[choice] : store._liquids[choice].vault).redeem(shares, receiver, owner);
    }

    function permit(
        uint256 amount,
        uint8 choice,
        bool stable
    ) external onlyStrategy {
        IVault(stable ? store._stables[choice] : store._liquids[choice].vault).temporaryPermit(amount, store._strategy);
    }

    // end of strategy calls

    function changeSVaultEntrypoint(uint256 index, address newEntrypoint) public onlyEditor {
        IVault(store._stables[index]).changeEntrypoint(newEntrypoint);
    }

    function changeLVaultEntrypoint(uint256 index, address newEntrypoint) public onlyEditor {
        IVault(store._liquids[index].vault).changeEntrypoint(newEntrypoint);
    }

    receive() external payable {}
}
