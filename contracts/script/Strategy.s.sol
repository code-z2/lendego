// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.13;

import "forge-std/Script.sol";
import "../src/tokens/ERC20/ERC20.sol";
import "../src/Strategy.sol";
import "../src/interface/IEntrypoint.sol";

contract DeployEgo is Script {
    function run() external {
        address dai = address(new Token("Dai", "DAI", 18));
        address usdc = address(new Token("USDC", "USDC", 6));
        address usdt = address(new Token("fwrapped USDT", "fUSDT", 6));
        address ftm = address(new Token("Wrapped Fantom", "wFTM", 18));
        address weth = address(new Token("Wrapped Ether", "WETH", 18));

        address[5] memory initialUnderlyings = [dai, usdc, usdt, ftm, weth];
        address router = 0xa6AD18C2aC47803E193F75c3677b14BF19B94883; // spookyswap router on ftm testnet

        address ftmusd = 0xe04676B9A9A2973BCb0D1478b5E1E9098BBB7f3D; // fantom testnet
        address ethusd = 0xB8C458C957a6e6ca7Cc53eD95bEA548c52AFaA24; // eth/usd on ftm testnet

        vm.startBroadcast();

        StrategyV1 strategy = new StrategyV1(initialUnderlyings, [router, usdc, weth], 0, msg.sender);

        address entrypoint = strategy.getEntrypoint();

        IEntrypointV1(entrypoint).setPriceFeedForVault(0, ftmusd);
        IEntrypointV1(entrypoint).setPriceFeedForVault(1, ethusd);

        vm.stopBroadcast();
    }
}
