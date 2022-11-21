// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.17;


contract CycleLend {
    
    enum AcceptedStables {
        USDC,
        DAI,
        USDT,
        FRAX,
        BUSD
    }

    enum AcceptedTenures {
        30D,
        60D,
        90D
    }

    struct Node {
        bytes32 nodeID: // optional node identifier
        address lender;
        address borrower;
        uint256 stableOut;
        uint256 collateralIn;
        address stable;
        address collateral;
        uint8 interestRate;
        uint256 tenure;
        bool filled; // default false
    }

    Node[] pool;

    constructor() {
        //set stables address
    }

    function createPosition(/** the lender provides the stable to use, x amount */ ) public view {
        // make function no rentrant
        // check allowance for the token.
        // transfer token of x amount to address(this)
        // requre trnasfer == success
        // create a new unfillled node
        // emit new loan available. (address lender, address stable, address amount, uint8 interest (cant be more than 15%), duration tenure)
    }

    function fillPosition(/** address collateral, uint256 nodeIDX*/) public view {
        // checks that collateral price >= 125% of requested stable
        // if collateral == address(0), check that msg.value price > 125% of requested stable
        // calls nodes[nodeIDX].fill
        // emit new loan filled (address borrower, address lender, address stable, address amount, duration tenure)
    }

    function exitLenderFromPosition(/** uint256 nodeidx */) public view  returns () {
        // checks that the tenure has expired
        // withdraws stable + interest from collateral wei amount equivlavent
        // move the node out of the pool into an unstable pool (not balanced: only one end is satisfied)
        //emit new lender exit (nodeId)
    }

    function exitCurrentBorrowerFromPosition() public view {
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

    function burnPosition() public view {
        // requires only msg.sender == node.lender
        // transfer stable from address(this) to lender
        // delete the node
    }

}