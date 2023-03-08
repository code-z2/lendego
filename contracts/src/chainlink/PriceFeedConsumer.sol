// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../tokens/ERC4626/Entrypoint.sol";

/**
 * @title The PriceConsumerV3 contract
 * @notice Acontract that returns latest price from Chainlink Price Feeds
 */
contract ArcmonPriceFeedConsumer {
    VaultsEntrypointV1 private immutable _entrypoint;

    constructor(address entrypoint) {
        _entrypoint = VaultsEntrypointV1(payable(entrypoint));
    }

    function getQuoteByExpectedOutput(
        uint256 maximumExpectedOutput,
        uint8 choice,
        uint8 lDecimals,
        uint8 collateralPercent
    ) external view returns (uint256) {
        require(maximumExpectedOutput <= 1000000 ether, "cannot take more than 1m ether");
        uint8 _collateralPErcent = collateralPercent > 125 ? 125 : collateralPercent;
        // +/-(0.5%) offset from collateral%
        uint256 leastOutput = (maximumExpectedOutput * _collateralPErcent) / 100 + 1 gwei;
        // using the decimals of the default usd token
        uint8 sDecimals = IVault(_entrypoint.getSVaults()[0]).decimals();
        return _scaleExpectedOutput(leastOutput, sDecimals, lDecimals, choice);
    }

    function scaleExpectedOutput(
        uint256 output,
        uint8 sDecimals,
        uint8 lDecimals,
        uint8 choice
    ) external view returns (uint256) {
        return _scaleExpectedOutput(output, sDecimals, lDecimals, choice);
    }

    function _scaleExpectedOutput(
        uint256 output,
        uint8 sDecimals,
        uint8 lDecimals,
        uint8 choice
    ) internal view returns (uint256) {
        int256 latesPrice = _getLatesPrice(_entrypoint.getLVaults()[choice].priceFeed);

        uint256 raw = (_scaleOutput(output, sDecimals, lDecimals) * 10 ** lDecimals) / uint256(latesPrice);

        return raw;
    }

    function _scaleOutput(uint256 output, uint8 sDecimals, uint8 expectedDecimals) internal pure returns (uint256) {
        if (sDecimals < expectedDecimals) {
            return output * 10 ** uint256(expectedDecimals - sDecimals);
        } else if (sDecimals > expectedDecimals) {
            return output / 10 ** uint256(sDecimals - expectedDecimals);
        }
        return output;
    }

    function getLatestPriceFromFeed(address feed) external view returns (int256) {
        return _getLatesPrice(feed);
    }

    function _getLatesPrice(address feed) internal view returns (int256) {
        (
            ,
            /* uint80 roundID */
            int256 price /* uint256 startedAt */ /* uint256 timeStamp */ /* uint80 answeredInRound */,
            ,
            ,

        ) = AggregatorV3Interface(feed).latestRoundData();

        return price;
    }
}
