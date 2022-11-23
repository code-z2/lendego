// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./tokens/mock/ERC20.sol";

import "ds-test/test.sol";
import "../src/tokens/ERC4626/vStable.sol";

contract StablesVaultTest is DSTest {
    StablesVault public vStable;
    MockToken public mock;
    address[5] assets;

    function setUp() public {
        mock = new MockToken();
        assets = [address(mock), address(mock), address(mock), address(mock), address(mock)];
        vStable = new StablesVault(assets, "vLendego", "vLDG");
    }

    function testStableTokensAreProvided() public {
        assertEq(vStable.asset()[0], address(mock));
    }
}
