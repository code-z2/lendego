// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title The PriceConsumerV3 contract
 * @notice Acontract that returns latest price from Chainlink Price Feeds
 */
contract PriceFeedConsumer {
    function getLatestPriceFromFeed(address feed) external view returns (int256) {
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
