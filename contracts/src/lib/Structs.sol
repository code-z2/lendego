// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

// represents an unfifilled order
struct PartialNodeL {
    // lenders entry
    address lender;
    uint8 choiceOfStable;
    uint8 interestRate;
    uint256 assets;
    bool filled; // default false
    bool acceptingRequests; // default true
    bool approvalBased; // default false
    uint8 minCollateralPercentage; // deault 125%
}

struct PartialNodeB {
    // borrowers details
    address borrower;
    address collateral;
    uint256 collateralIn;
    uint256 maximumExpectedOutput; // usd
    uint8 tenure;
    uint8 indexOfCollateral;
    uint8 maxPayableInterest;
    bool restricted;
}

struct Node {
    uint256 nodeId; // unique node identifier
    uint timeStamp; // timestamp when node was created
    bool isOpen; // if the positions represented by this node are still open
    bool isPending; // position lend is approvalBased
    PartialNodeL lend; // the lenders details
    PartialNodeB borrow; // the borrowers details
}

struct Tokens {
    address vault;
    address priceFeed;
}

struct EntrypointVars {
    address _editor;
    address _strategy;
    address[] _stables;
    Tokens[] _liquids;
}