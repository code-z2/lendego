// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.13;

import "forge-std/Script.sol";
import "../src/tokens/ERC20/ERC20.sol";
import "../src/Strategy.sol";
import "../src/interface/IEntrypoint.sol";
import "../src/tokens/ERC4626/Entrypoint.sol";
import "../src/tokens/ERC4626/Vault.sol";
import "../src/extensions/PersonalisedLending.sol";
import "../src/extensions/TrustedLending.sol";

contract DeployStrategy is Script {
    function run() external {
        vm.startBroadcast();

        Token dai = new Token("Dai", "DAI", 18);
        Token usdc = new Token("USDC", "USDC", 6);
        Token usdt = new Token("fwrapped USDT", "fUSDT", 6);
        Token ftm = new Token("Wrapped Fantom", "wFTM", 18);
        Token weth = new Token("Wrapped Ether", "WETH", 18);

        address[3] memory diffuserParams = [0xa6AD18C2aC47803E193F75c3677b14BF19B94883, address(usdc), address(weth)];

        TrustedLending trustee = new TrustedLending();
        Personalisation personalized = new Personalisation(msg.sender, address(0));

        VaultsEntrypointV1 entrypoint = new VaultsEntrypointV1();
        address entrypointAddr = address(entrypoint);

        // deploy five vaults
        Vault vdai = new Vault(dai, "alchemy DAI", "svDAI", entrypointAddr);
        Vault vusdc = new Vault(usdc, "alchemy USDC", "svUSDC", entrypointAddr);
        Vault vusdt = new Vault(usdt, "alchemy USDT", "svUSDT", entrypointAddr);
        Vault vftm = new Vault(ftm, "alchemy FTM", "lvFTM", entrypointAddr);
        Vault vweth = new Vault(weth, "alchemy WETH", "lvWETH", entrypointAddr);

        StrategyV1 strategy = new StrategyV1(entrypointAddr, address(personalized), address(trustee), diffuserParams);

        entrypoint.addNewSVault(address(vdai));
        entrypoint.addNewSVault(address(vusdc));
        entrypoint.addNewSVault(address(vusdt));
        entrypoint.addNewLVault(address(vftm), 0xe04676B9A9A2973BCb0D1478b5E1E9098BBB7f3D);
        entrypoint.addNewLVault(address(vweth), 0xB8C458C957a6e6ca7Cc53eD95bEA548c52AFaA24);

        entrypoint.setStrategyContract(address(strategy));
        personalized.setStrategy(address(strategy));

        vm.stopBroadcast();
    }
}
