// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.13;

import "forge-std/Script.sol";
import "../src/Ego.sol";
import "../src/tokens/ERC20/ERC20.sol";

contract DeployEgo is Script {
    function run() external {
        address usdc = address(new Token("USDC", "USDC", 9));
        address dai = address(new Token("Dai", "DAI", 9));
        address usdt = address(new Token("USD Tether", "USDT", 9));
        address busd = address(new Token("Binance USD", "BUSD", 9));
        address frax = address(new Token("Fraxshare", "FRAX", 9));

        address[5] memory stables = [usdc, dai, usdt, busd, frax];

        vm.startBroadcast();

        new Ego(stables);

        vm.stopBroadcast();
    }
}
