// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.13;

import "forge-std/Script.sol";
import "../src/utils/DiaOracle.sol";

contract DeployDiaOracle is Script {
    function run() external {
        vm.startBroadcast();

        new DiaOracle();

        vm.stopBroadcast();
    }
}
