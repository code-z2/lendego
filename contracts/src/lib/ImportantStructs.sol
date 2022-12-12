// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.17;

enum AcceptedStables {
    USDC,
    DAI,
    USDT,
    BUSD,
    FRAX
}

// represents an unfifilled order
struct PartialNodeL {
    // lenders entry
    address lender;
    AcceptedStables choiceOfStable;
    uint8 interestRate;
    uint256 assets;
    bool filled; // default false
    bool acceptingRequests; // default true
}

struct PartialNodeB {
    // borrowers details
    address borrower;
    address collateral;
    uint256 collateralIn;
    uint256 maximumExpectedOutput; // usd
    uint128 tenure;
    uint128 indexOfCollateral;
    uint8 maxPayableInterest;
    bool restricted;
}

struct Node {
    uint256 nodeId; // unique node identifier
    uint timeStamp; // timestamp when node was created
    bool isOpen; // if the positions represented by this node are still open
    PartialNodeL lend; // the lenders details
    PartialNodeB borrow; // the borrowers details
}

struct Tokens {
    address token;
    address priceOracle;
    string pair;
}
