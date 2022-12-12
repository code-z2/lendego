// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.17;

import "./Borrow.sol";
import "./Lend.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import {Node} from "./lib/ImportantStructs.sol";

contract Ego is Lend, Borrow {
    using Counters for Counters.Counter;

    Counters.Counter private _nodeIdCounter;

    // the default stable-coin
    AcceptedStables private defaultChoice = AcceptedStables.USDC;

    // general pool
    mapping(uint => Node) private pool;
    // used to keep track of lenders stables that cannot be withrawn due to open positions
    mapping(address => uint256) private lockedStables;

    constructor(address[5] memory stables) Lend(stables) {}

    event LoanTaken(address by, address from, uint256 amount, uint128 tenure);
    event LoanSettled(address by, address lender, uint256 amount, uint256 nodeId);

    function fillPosition(
        uint128 selectedCollateral,
        uint256 collateralIn_,
        uint256 partialNodeLIdx,
        uint256 tenure
    ) public {
        require(tenure < 3, "Tenure: not surpported");
        require(partialNodeLIdx < lPool.length, "Lender: the selected lender does not exist");
        require(selectedCollateral < liquidV.asset().length, "Liquid: the selected collateral is not surpported");
        require(lPool[partialNodeLIdx].acceptingRequests, "Notice: lender is currently not accepting requests");

        address collateral = liquidV.asset()[selectedCollateral].token;
        // calculate 125% of maximumExpectedOutput in usd
        uint256 assets = getQuoteByExpectedOutput(
            lPool[partialNodeLIdx].assets,
            IERC20Plus(stableV.asset()[uint(lPool[partialNodeLIdx].choiceOfStable)]).decimals(),
            selectedCollateral
        );
        // cannot deposit less than 125% of collateral
        require(collateralIn_ >= assets, "Minimum collateral threshold not satisfied");
        // deducts borrowers funds
        bool success = liquidV.deposit(msg.sender, collateralIn_, selectedCollateral);
        // creates borrower node
        PartialNodeB memory borrower = PartialNodeB({
            borrower: msg.sender,
            collateral: collateral,
            collateralIn: collateralIn_,
            maximumExpectedOutput: lPool[partialNodeLIdx].assets,
            tenure: acceptedTenures[tenure],
            indexOfCollateral: selectedCollateral,
            maxPayableInterest: lPool[partialNodeLIdx].interestRate,
            restricted: false
        });
        // temporary partial node holder
        PartialNodeL memory lender = lPool[partialNodeLIdx];
        lender.filled = true;
        if (success) {
            bool handled = _handleNodeService(borrower, lender);
            if (handled) {
                // calls partialNodeLIdx.fill
                lPool[partialNodeLIdx].filled = true;
                emit LoanTaken(
                    msg.sender,
                    lPool[partialNodeLIdx].lender,
                    lPool[partialNodeLIdx].assets,
                    acceptedTenures[tenure]
                );
                // if value exchange fails, just broadcast borrower
            } else bPool.push(borrower);
        }
    }

    function fillUnstablePosition(uint256 partialNodeBIdx) public {
        require(!bPool[partialNodeBIdx].restricted, "borrowers node either defaulted or was liquidated");
        // only usdc is allowed for unstable positions
        // deposit into the vault
        bool success = stableV.deposit(msg.sender, bPool[partialNodeBIdx].maximumExpectedOutput, uint(defaultChoice));
        // create new position
        PartialNodeL memory lender = PartialNodeL({
            lender: msg.sender,
            choiceOfStable: defaultChoice,
            interestRate: bPool[partialNodeBIdx].maxPayableInterest,
            assets: bPool[partialNodeBIdx].maximumExpectedOutput,
            filled: true,
            acceptingRequests: true
        });

        if (success) {
            // if the lender deposited, then add him to pool
            lPool.push(lender);
            // handle money exchange
            bool handled = _handleNodeService(bPool[partialNodeBIdx], lender);
            if (handled) {
                _removeUnstableItemFromPool(partialNodeBIdx);
                emit LoanTaken(
                    bPool[partialNodeBIdx].borrower,
                    msg.sender,
                    bPool[partialNodeBIdx].maximumExpectedOutput,
                    bPool[partialNodeBIdx].tenure
                );
            }
        }
    }

    function exitLenderFromPosition(uint256 nodeId) public {
        require(msg.sender == pool[nodeId].lend.lender, "Lender: you are not the lender attached to this node");
        require(pool[nodeId].isOpen, "position has been closed");
        require(_hasTenureExpired(pool[nodeId]), "sorry loan tenure is still active");
        // caution with this
        _forcefullyExit(nodeId);
        // emit loan settled;
        emit LoanSettled(pool[nodeId].borrow.borrower, pool[nodeId].lend.lender, pool[nodeId].lend.assets, nodeId);
        pool[nodeId].isOpen = false;
    }

    function exitBorrowerFromPosition(uint256 nodeId, address reciever) public returns (bool complete) {
        require(msg.sender == pool[nodeId].borrow.borrower, "Borrower: you did not fill this position!");
        require(pool[nodeId].isOpen, "position has been closed");
        // todo: check balance of liquidV before attempting
        Node memory node = pool[nodeId];
        // transfers loan + interest back to stablesVault;
        // user handles the approval here
        // ! @audit this is rentrant, but at the benefit of the lender
        // ? how: the attacker must successfully deposit money, which increments the lenders shares
        bool success = _transfer(
            stableV.asset()[uint(node.lend.choiceOfStable)],
            msg.sender,
            address(stableV),
            calcLoanPlusInterest(nodeId)
        );
        if (success) {
            lockedStables[node.lend.lender] -= node.lend.assets;
            // mints lender some more shares
            stableV.mint(node.lend.lender, calcInterestOnly(nodeId));
            // closes position
            pool[nodeId].isOpen = false;
            // transfers collateral from liquidV to borrower
            complete = liquidV.withdraw(msg.sender, node.borrow.collateralIn, reciever, node.borrow.indexOfCollateral);
            // emit loan settled event();
            emit LoanSettled(node.borrow.borrower, node.lend.lender, node.lend.assets, nodeId);
        }
    }

    function calcLoanPlusInterest(uint256 nodeId) public view returns (uint256) {
        return pool[nodeId].lend.assets + calcInterestOnly(nodeId);
    }

    function calcInterestOnly(uint256 nodeId) public view returns (uint256) {
        return (pool[nodeId].lend.assets * pool[nodeId].lend.interestRate) / 100;
    }

    function extendLoanDuration(uint256 nodeId) public {
        // loanee requests for node.lend.tenure += 15
        require(msg.sender == pool[nodeId].borrow.borrower, "Borrower: you did not fill this position!");
        require(!_hasTenureExpired(pool[nodeId]), "OOPS! sorry you can no longer extend your loan tenure");
        require(pool[nodeId].isOpen, "position has been closed");
        // sets node.borrow.tenure += 15
        pool[nodeId].borrow.tenure += 15;
        // gets interest for tenure and interest for +15days
        //  new interest = base interest + new interest / (duration / 15 ) e.g 2% + 2% / (60/15) => 2 + 0.5 == 2.5
        uint8 oldInterst = pool[nodeId].lend.interestRate;
        uint8 newInterest = oldInterst / uint8(pool[nodeId].borrow.tenure / 15) + oldInterst;
        // sets node.lend.interestRate to new interest.
        // reminder, interest rate cannot be more than 15%
        (newInterest > 15) ? pool[nodeId].lend.interestRate = 15 : pool[nodeId].lend.interestRate = newInterest;
    }

    function getAllPositions() public view returns (Node[] memory) {
        uint256 currentNodeId = _nodeIdCounter.current();
        Node[] memory allNodes = new Node[](currentNodeId);
        for (uint i = 0; i < currentNodeId; i++) {
            allNodes[i] = pool[i];
        }
        return allNodes;
    }

    // deactivates the lenders node
    // no more match can be made, and position can be burnt
    function deactivateLenderNode(uint256 partialNodeLIdx) public {
        require(
            msg.sender == lPool[partialNodeLIdx].lender,
            "Lender: you are not the lender that owns this node or it does not exist"
        );
        lPool[partialNodeLIdx].acceptingRequests = false;
    }

    function withdraw(uint256 assets, address receiver, uint8 choice) public returns (uint256 amount) {
        require(
            assets < (stableV.getshares(msg.sender) - lockedStables[msg.sender]),
            "cannot withdraw more than allowed"
        );
        amount = stableV.withdraw(msg.sender, assets, receiver, msg.sender, choice);
    }

    function redeem(uint256 shares, address receiver, uint8 choice) public returns (uint256 amount) {
        require(
            shares < (stableV.balanceOf(msg.sender) - lockedStables[msg.sender]),
            "cannot redeem more than allowed"
        );
        amount = stableV.redeem(msg.sender, shares, receiver, msg.sender, choice);
    }

    function _handleNodeService(PartialNodeB memory borrower, PartialNodeL memory lender) internal returns (bool) {
        uint256 currentNode = _nodeIdCounter.current();
        // creates paired node
        Node memory new_ = Node({
            nodeId: currentNode,
            timeStamp: block.timestamp,
            isOpen: true,
            lend: lender,
            borrow: borrower
        });
        // transfers expected usd to borrower
        bool permitted = stableV.temporaryPermit(uint(lender.choiceOfStable), lender.assets);
        if (permitted) {
            bool success = _transfer(
                stableV.asset()[uint(lender.choiceOfStable)],
                address(stableV),
                borrower.borrower,
                lender.assets
            );
            if (success) {
                // broadcasts paired node
                pool[currentNode] = new_;
                // increments nodeid counter
                _nodeIdCounter.increment();
                // lock lenders funds
                lockedStables[lender.lender] += lender.assets;
                return true;
            }
        }
        return false;
    }

    function _transfer(address contract_, address from, address to, uint256 amount) internal returns (bool success) {
        success = IERC20Plus(contract_).transferFrom(from, to, amount);
    }

    function _hasTenureExpired(Node memory node) internal view returns (bool) {
        // check if tenure has expired
        return block.timestamp > node.timeStamp + node.borrow.tenure * 1 days;
    }

    // entry point for liquidation and lender exit
    function _forcefullyExit(uint256 nodeId) internal {
        Node memory node = pool[nodeId];
        // remove the initial funds first
        (uint128 latestPrice, ) = IDIAOracleV2(liquidV.asset()[node.borrow.indexOfCollateral].priceOracle).getValue(
            liquidV.asset()[node.borrow.indexOfCollateral].pair
        );
        // extra 2$ for gas price
        uint256 initialFunds = (node.lend.assets + 2000000000) / latestPrice;
        // assuming diffusion swap has be carried out on collateral
        _swapAtDiffussion(initialFunds, node.borrow.indexOfCollateral);
        // unlocks stable of collateral wei amount equivlavent
        lockedStables[node.lend.lender] -= node.lend.assets;
        // reconstruct a restricted node
        node.borrow.restricted = true;
        node.borrow.collateralIn -= initialFunds;
        // then try to collect interest.
        uint256 interests = calcInterestOnly(nodeId) / latestPrice;
        // sell assets equivalent on diffussion swap
        bool success = _swapAtDiffussion(interests, node.borrow.indexOfCollateral);
        if (success) {
            // mint lender interest shares
            stableV.mint(node.lend.lender, calcInterestOnly(nodeId));
            // update the nodes finall collateralIn
            if (interests < node.borrow.collateralIn) node.borrow.collateralIn -= interests;
        }
        //  excess collateral will be moved to exitedPool, borrower can then scalp his remains from there
        bPool.push(node.borrow);
    }

    function _swapAtDiffussion(uint256 amount, uint256 selectedCollateral) internal pure returns (bool) {
        // todo this function is meant to swap collateral back to defaultChoice from diffussion swap
        // todo moves the funds back to stable vault
        // diffussion.swap(address(selectedCollateral), defaultChoice, amount);
        amount + selectedCollateral; // just to silent warnings
        return true;
    }
}
