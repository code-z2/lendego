// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./tokens/mock/ERC20.sol";

import "ds-test/test.sol";
import "../src/tokens/ERC4626/vStable.sol";

contract CounterTest is DSTest {
    StablesVault public vStable;
    MockToken public mock;
    IERC20[5] assets;

    function setUp() public {
        mock = new MockToken();
        assets = [
            IERC20(address(mock)),
            IERC20(address(mock)),
            IERC20(address(mock)),
            IERC20(address(mock)),
            IERC20(address(mock))
        ];
        vStable = new StablesVault(assets, "vLendego", "vLDG");
    }

    function testStableTokensAreProvided() public {
        // assertEq(vStable._assets[0], assets[0]);
    }
}
