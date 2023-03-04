// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Diffuse is ReentrancyGuard, Ownable {
    IUniswapV2Router02 public immutable router;
    IERC20 public immutable usd;
    IWETH public immutable weth;

    constructor(address routerAddress, address usdToken, address wethAddress) {
        router = IUniswapV2Router02(routerAddress);
        usd = IERC20(usdToken);
        weth = IWETH(wethAddress);
    }

    function getPath(address tokenIn) public view returns (address[] memory) {
        address _weth = address(weth);
        address _usd = address(usd);
        address[] memory path;

        if (tokenIn == _weth) {
            path = new address[](2);
            path[0] = tokenIn;
            path[1] = _usd;
        } else {
            path = new address[](3);
            path[0] = tokenIn;
            path[1] = _weth;
            path[2] = _usd;
        }
        return path;
    }

    function diffuse(uint256 amount, IERC20 tokenIn, address vault) external nonReentrant onlyOwner {
        require(tokenIn != usd, "usd swap disallowed");
        address[] memory path = getPath(address(tokenIn));

        tokenIn.approve(address(router), amount);
        router.swapExactTokensForTokens(
            amount,
            router.getAmountsOut(amount, path)[path.length - 1],
            path,
            vault,
            block.timestamp + 15
        );
    }

    function refund(IERC20 tokenOut, address vaultAddress) external onlyOwner {
        tokenOut.transfer(vaultAddress, tokenOut.balanceOf(address(this)));
    }

    receive() external payable {}
}
