// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.17;

import "./Borrow.sol";
import "./Lend.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Ego is Lend, Borrow {
    using Counters for Counters.Counter;

    Counters.Counter private _nodeIdCounter;
    struct Node {
        uint nodeId; // unique node identifier
        uint timeStamp; // timestamp when node was created
        bool isOpen; // if the positions represented by this node are still open
        PartialNodeL lend; // the lenders details
        PartialNodeB borrow; // the borrowers details
    }

    // general pool
    mapping(uint => Node) pool;

    constructor(address[5] memory stables) Lend(stables) {}

    event LoanTaken(address by, address from, uint256 amount, uint128 tenure);

    function fillPosition(uint128 selectedCollateral, uint256 partialNodeLIdx, uint256 tenure) public {
        require(tenure >= 0 && tenure < 3, "Tenure: not surpported");
        require(partialNodeLIdx < lPool.length, "Lender: the selected lender does not exist");
        require(selectedCollateral < liquidV.asset().length, "Liquid: the selected collateral is not surpported");

        uint256 currentNode = _nodeIdCounter.current();
        address collateral = liquidV.asset()[selectedCollateral].token;
        // calculate 125% of maximumExpectedOutput in usd
        uint256 assets = getQuoteByExpectedOutput(lPool[partialNodeLIdx].assets, selectedCollateral);
        // creates borrower node
        PartialNodeB memory borrower = PartialNodeB({
            borrower: msg.sender,
            collateral: collateral,
            collateralIn: assets,
            maximumExpectedOutput: lPool[partialNodeLIdx].assets,
            tenure: acceptedTenures[tenure],
            indexOfCollateral: selectedCollateral
        });
        // deducts borrowers funds
        bool success = liquidV.deposit(msg.sender, assets, selectedCollateral);
        if (success) {
            // calls partialNodeLIdx.fill
            lPool[partialNodeLIdx].filled = true;
            // creates paired node
            Node memory new_ = Node({
                nodeId: currentNode,
                timeStamp: block.timestamp,
                isOpen: true,
                lend: lPool[partialNodeLIdx],
                borrow: borrower
            });
            // broadcasts paired node
            pool[currentNode] = new_;
            // increments nodeid counter
            _nodeIdCounter.increment();
            // transfers expected usd to borrower
            IERC20(stableV.asset()[uint(lPool[partialNodeLIdx].choiceOfStable)]).transferFrom(
                address(stableV),
                msg.sender,
                lPool[partialNodeLIdx].assets
            );
            emit LoanTaken(
                msg.sender,
                lPool[partialNodeLIdx].lender,
                lPool[partialNodeLIdx].assets,
                acceptedTenures[tenure]
            );
        }
    }

    function fillUnstablePosition(uint256 tenure) public pure /** address collateral, uint256 nodeIDX*/ {
        require(tenure >= 0 && tenure < 3, "Tenure: not surpported");
        // checks that collateral price >= 125% of requested stable
        // if collateral == address(0), check that msg.value price > 125% of requested stable
        // calls nodes[nodeIDX].fill
        // emit new loan filled (address borrower, address lender, address stable, address amount, duration tenure)
    }

    function exitLenderFromPosition(uint256 nodeIdx) public view {
        require(msg.sender == pool[nodeIdx].lend.lender, "Lender: you are not the lender attached to this node");
        // checks that the tenure has expired
        // msg.sender must be Node.lender.lender
        // withdraws stable + interest from collateral wei amount equivlavent
        // move the node out of the pool into an unstable pool (not balanced: only one end is satisfied)
        //emit new lender exit (nodeId)
    }

    function exitBorrowerFromPosition() public view {
        // closes position
        // sets lendersNode.filled == false
        // transfers loan + interest back to address(this);
        // exit borrower collateral from osmosis liquidity
        // transfers collateral from address(this) to borrower
        // emit loan settled event();
    }

    function extendLoanDuration() public view {
        // loanee requests for node.tenure += 15
        // sets node.tenure += 15
        // gets interest for 30 day and interest for +15days
        //  new interest = base interest + new interest / (duration / 15 ) e.g 2% + 2.5% / (60/15) => 2 + 2.5 / 4 == 2.625
        // sets node.interest to new interest.
        // set other stuffs
    }
}
