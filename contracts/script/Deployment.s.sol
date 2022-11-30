// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/tokens/ERC20/DevERC20.sol";
import "../src/lib/utils/DiaOracle.sol";
import "../src/Ego.sol";
import "../src/interface/ILiquidVault.sol";

contract DeploymentScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        // deploy all contracts
        Atom atom = new Atom();
        WrappedETH weth = new WrappedETH();
        USDC usdc = new USDC();
        Dia dia = new Dia();
        TestOracle oracle = new TestOracle();
        Ego ego = new Ego([address(usdc), address(usdc), address(usdc), address(usdc), address(usdc)]);

        // set the appropriate contracts params
        address lv = ego.getLiquidVaultAddress();
        address sv = ego.getStableVaultAddress();
        ILiquidVault(lv).addNew(address(atom), address(oracle), "ATOM/USD");
        ILiquidVault(lv).addNew(address(weth), address(oracle), "WETH/USD");
        ILiquidVault(lv).addNew(address(dia), address(oracle), "DIA/USD");

        // just preapprove me
        usdc.approve(sv, 1000);
        atom.approve(lv, 1000);
        dia.approve(lv, 1000);
        weth.approve(lv, 1000);

        vm.stopBroadcast();
    }
}
