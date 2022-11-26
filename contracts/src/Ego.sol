// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.17;

import "./Borrow.sol";
import "./Lend.sol";

contract Ego is Lend, Borrow {
    struct Node {
        uint nodeId;
        uint timeStamp;
        PartialNodeL lend;
        PartialNodeB borrow;
    }

    // general pool
    mapping(uint => Node) pool;

    constructor(address[5] memory stables) Lend(stables) {}

    function fillPosition(uint256 tenure) public pure /** address collateral, uint256 nodeIDX*/ {
        require(tenure >= 0 && tenure < 3, "Tenure: not surpported");
        // checks that collateral price >= 125% of requested stable
        // if collateral == address(0), check that msg.value price > 125% of requested stable
        // calls nodes[nodeIDX].fill
        // emit new loan filled (address borrower, address lender, address stable, address amount, duration tenure)
    }

    function fillUnstablePosition(uint256 tenure) public pure /** address collateral, uint256 nodeIDX*/ {
        require(tenure >= 0 && tenure < 3, "Tenure: not surpported");
        // checks that collateral price >= 125% of requested stable
        // if collateral == address(0), check that msg.value price > 125% of requested stable
        // calls nodes[nodeIDX].fill
        // emit new loan filled (address borrower, address lender, address stable, address amount, duration tenure)
    }

    function exitLenderFromPosition(uint256 nodeIdx) public view returns (bool) {
        require(msg.sender == pool[nodeIdx].lend.lender, "Lender: you are not the lender attached to this node");
        // checks that the tenure has expired
        // msg.sender must be Node.lender.lender
        // withdraws stable + interest from collateral wei amount equivlavent
        // move the node out of the pool into an unstable pool (not balanced: only one end is satisfied)
        //emit new lender exit (nodeId)
    }

    function exitBorrowerFromPosition() public view {
        // sets node.filled == false
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
