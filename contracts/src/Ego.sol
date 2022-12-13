// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.17;

import "./Borrow.sol";
import "./Lend.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import {Node} from "./lib/ImportantStructs.sol";

/**
 * @title Ego - peer to peer lending and borrowing
 * @author - peter anyaogu
 * @notice - this contract is the main entry point to the entire alchemoney logic.
 * all deposits, withdrawals and positions are made from within the EGO boudaries
 * @dev - please see IEgo interface in interface/IEgo
 */
contract Ego is Lend, Borrow {
    using Counters for Counters.Counter;
    // private counter used to hold current nodeId
    Counters.Counter private _nodeIdCounter;

    // the default stable-coin
    AcceptedStables private defaultChoice = AcceptedStables.USDC;

    // general pool
    mapping(uint => Node) private pool;
    // used to keep track of lenders stables that cannot be withrawn due to open positions
    mapping(address => uint256) private lockedStables;

    constructor(address[5] memory stables) Lend(stables) {}

    /**
     * @notice emitted when a taker fills a stable position
     * @dev partialNodeL + un-broadcasted partialNodeB merges into a full node
     * @param by - the taker (msg.sender)
     * @param from - the lender
     * @param amount - the total amount transfered to (by) in usd
     * @param tenure - the expected loan duration (30, 60, 90) days
     */
    event LoanTaken(address indexed by, address indexed from, uint256 indexed amount, uint128 tenure);
    /**
     * @notice emitted when a taker refunds the money taken
     * @dev Node.isOpen == false; a taker archives a position
     * @param by - the taker (msg.sender)
     * @param lender - address of the lender who provided the money
     * @param amount - the total amount taken by the taker excluding interests
     * @param nodeId - the unique node identifier (node index in mapping)
     */
    event LoanSettled(address indexed by, address indexed lender, uint256 indexed amount, uint256 nodeId);
    /**
     * @notice emitted when a taker extends loan tenure
     * @dev node.borrower.tenure += 15 days
     * @param nodeId the node of id nodeId to extend loan tenure
     */
    event LoanExtended(uint256 indexed nodeId);

    /**
     * @notice - only called by the taker - takes out loan from a specific lender (partialNodeLIdx)
     * @dev - taker merges with a lender without broadcasting a new partialNodeB.
     * @param selectedCollateral - the ID collateral to be used in the new position
     * @param collateralIn_ - the total amount of collateral with ID (selectedCollateral). must be greater than 125% of expected output
     * @param partialNodeLIdx - the lnode id of the position that is to merged with
     * @param tenure - the tenure index (0,1,2) to be used to fetch the corresponding tenure from an array
     */
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
            IERC20Metadata(stableV.asset()[uint(lPool[partialNodeLIdx].choiceOfStable)]).decimals(),
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
        // temporary partial node holder in memory
        PartialNodeL memory lender = lPool[partialNodeLIdx];
        // sets the partialnode in memory to filled
        lender.filled = true;
        if (success) {
            bool handled = _handleNodeService(borrower, lender);
            if (handled) {
                // calls partialNodeLIdx.fill; sets partialnode in storage to filled
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

    /**
     * @notice - only called by the lender, fufils the loan request of a taker
     * @dev - since a the node to be fufilled is the takers bnode, the taker can only request the Default choice USDC
     * the lender merges with a taker but broadcasts lnode as filled.
     * it is broadcasted because initially, the plan was to have the lender reuse the lnode after taker exits
     * @param partialNodeBIdx - the bnode id of the taker
     */
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
                // removes bnode of id partialNodeBIdx from the bpool
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

    /**
     * @notice - when a position has exceeded loan tenure, the lender can call this metheod
     * @dev - this method sells of the takers collateral and recovers the loan (+ interest) in favour of the lender
     * it does not guaranty that interest will be recovered. but however the base amount == loan taken will be recovered
     * lender can only have access to this method once the loan tenure has expired
     * @param nodeId - the node id for the position which a lender is part of.
     */
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

    /**
     * @notice - settles the loan, the taker refunds back the loan and deposits the extra interest acrued
     * mints the lender extra shares coresponding to the interest accrued
     * the extra shares minted to the lender can only be redeemed
     * @param nodeId - the node id for the position the taker wishes to settle
     * msg.sender must hold the partialNodeB position.
     * @param reciever - the address of whom to recieve the takers (msg.sender) collaterals
     * @return complete - true/false (if the  collateral was succefully transfered to the reciever)
     */
    function exitBorrowerFromPosition(uint256 nodeId, address reciever) public returns (bool complete) {
        require(msg.sender == pool[nodeId].borrow.borrower, "Borrower: you did not fill this position!");
        require(pool[nodeId].isOpen, "position has been closed");
        // todo: check balance of liquidV before attempting
        Node memory node = pool[nodeId];
        // transfers loan + interest back to stablesVault;
        // user handles the approval here
        // ! @audit this is rentrant, but at the benefit of the lender
        // ? how: the attacker must successfully deposit money, which increments the lenders shares
        // todo: add rentrancy guard
        bool success = _transfer(
            stableV.asset()[uint(node.lend.choiceOfStable)],
            msg.sender,
            address(stableV),
            calcLoanPlusInterest(nodeId)
        );
        if (success) {
            // unlocks lenders shares
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

    /**
     * @notice calculates the loan + total interest accrued by the taker for a position (Node)
     * @param nodeId - the nodeId to perfom loan + interest calculations on
     * @custom:references -  calcInterestOnly
     */
    function calcLoanPlusInterest(uint256 nodeId) public view returns (uint256) {
        return pool[nodeId].lend.assets + calcInterestOnly(nodeId);
    }

    /**
     * @notice - given nodeId, calculates the total interest accrued to a taker in a position
     * @param nodeId - the nodeId to calculate interests accrued
     * @return interest
     */
    function calcInterestOnly(uint256 nodeId) public view returns (uint256) {
        return (pool[nodeId].lend.assets * pool[nodeId].lend.interestRate) / 100;
    }

    /**
     * @notice extends the loan tenure for a positon (Node) by extra 15days
     * @dev - loan tenure can only be extended by 15 days and can only be done once
     * @param nodeId - the node of id nodeId to extend
     */
    function extendLoanDuration(uint256 nodeId) public {
        // loanee requests for node.lend.tenure += 15
        require(msg.sender == pool[nodeId].borrow.borrower, "Borrower: you did not fill this position!");
        require(!_hasTenureExpired(pool[nodeId]), "OOPS! sorry you can no longer extend your loan tenure");
        require(pool[nodeId].isOpen, "position has been closed");
        require(pool[nodeId].borrow.tenure % 30 == 0, "loan tenure can only be extended once");
        // sets node.borrow.tenure += 15
        pool[nodeId].borrow.tenure += 15;
        // gets interest for tenure and interest for +15days
        //  new interest = base interest + new interest / (duration / 15 ) e.g 2% + 2% / (60/15) => 2 + 0.5 == 2.5
        uint8 oldInterst = pool[nodeId].lend.interestRate;
        uint8 newInterest = oldInterst / uint8(pool[nodeId].borrow.tenure / 15) + oldInterst;
        // sets node.lend.interestRate to new interest.
        // reminder, interest rate cannot be more than 15%
        (newInterest > 15) ? pool[nodeId].lend.interestRate = 15 : pool[nodeId].lend.interestRate = newInterest;
        emit LoanExtended(nodeId);
    }

    ///@return all the positions (Nodes) in the active pool
    function getAllPositions() public view returns (Node[] memory) {
        uint256 currentNodeId = _nodeIdCounter.current();
        Node[] memory allNodes = new Node[](currentNodeId);
        for (uint i = 0; i < currentNodeId; i++) {
            allNodes[i] = pool[i];
        }
        return allNodes;
    }

    ///@notice deactivates the lenders node and cannot be filled by taker, and position can be burnt
    function deactivateLenderNode(uint256 partialNodeLIdx) public {
        require(
            msg.sender == lPool[partialNodeLIdx].lender,
            "Lender: you are not the lender that owns this node or it does not exist"
        );
        lPool[partialNodeLIdx].acceptingRequests = false;
    }

    /**
     * @notice withraws unlocked amount of (assets) from Vault for token (USD token) of (choice) from the lenders (msg.sender) shares
     * @dev burns svLE (vault) tokens and withdraws amount (assets) to the (reciever)
     * @param assets - the amount of unlocked svLE to burn
     * @param receiver - the address to withdraw the assets (USD) to
     * @param choice - the choiceOfStable to withsraw (provided there's sufficient liquidity in the vault)
     * @return amount - the amount  of shares successfully withdrawn
     */
    function withdraw(uint256 assets, address receiver, uint8 choice) public returns (uint256 amount) {
        require(
            assets < (stableV.getshares(msg.sender) - lockedStables[msg.sender]),
            "cannot withdraw more than allowed"
        );
        amount = stableV.withdraw(msg.sender, assets, receiver, msg.sender, choice);
    }

    /**
     * @notice redeems unrecorded shares from Vault for token (USD token) of (choice) from the lenders (msg.sender) total shares
     * @dev burns svLE (vault) tokens and reedems amount (shares) to the (reciever) provided that (shares) + totalLocked < totalShares
     * @param shares - the amount of unrecorded svLE to burn
     * @param receiver - the address to redeem the shares  to
     * @param choice - the choiceOfStable to redeem (provided there's sufficient liquidity in the vault)
     * @return amount - the amount  of shares successfully redeemed
     */
    function redeem(uint256 shares, address receiver, uint8 choice) public returns (uint256 amount) {
        require(
            shares < (stableV.balanceOf(msg.sender) - lockedStables[msg.sender]),
            "cannot redeem more than allowed"
        );
        amount = stableV.redeem(msg.sender, shares, receiver, msg.sender, choice);
    }

    /**
     * @dev only devs: handles the creation of a new position (Node) by merging an lnode and bnode.
     * non-reverting - if the creation fails, does not revert.
     * @param borrower the takers bnode.
     * @param lender the lenders lnode.
     * @return boolean - if the creation is successfull or not.
     */
    function _handleNodeService(PartialNodeB memory borrower, PartialNodeL memory lender) internal returns (bool) {
        // gets the current node count
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
        // checks that the vault has enough one-time allowance to permit this transfer
        if (permitted) {
            // transfers loan from stables vault to taker
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

    /**
     * @dev only devs: handles the transfer of funds from vaults to taker/lender
     * @param contract_: the vault to transfer money from
     * @param to: the reciver of the funds
     * @param amount: the total (amount) to transfer from the (vault) to (to)
     * @return success - if the transfer is successfull or not
     */
    function _transfer(address contract_, address from, address to, uint256 amount) internal returns (bool success) {
        success = IERC20Metadata(contract_).transferFrom(from, to, amount);
    }

    /**
     * @dev only devs: checks whether the position (Node) loan tenure has expired
     * @param node: the node (typeof Struct Node) to check
     * @return boolean: expired or not...
     */
    function _hasTenureExpired(Node memory node) internal view returns (bool) {
        // check if tenure has expired
        return block.timestamp > node.timeStamp + node.borrow.tenure * 1 days;
    }

    /**
     * @dev only devs: entry point for liquidation and lender exit
     * first sells of 80% - 100% of the money involved in the position (Node)
     * tries to sell of the interest.
     * if it fails caontinues without reverting and forfeit interest accrued
     * restricts the bnode holder for this position (Node)
     * move the bnode with the remaining collateral (unsold) back to bpool
     * taker can then scalp his remains by burning the position.
     * @param nodeId - the node of id nodeId to sell of
     */
    function _forcefullyExit(uint256 nodeId) internal {
        Node memory node = pool[nodeId];
        // remove the initial funds first
        (uint128 latestPrice, ) = IDIAOracleV2(liquidV.asset()[node.borrow.indexOfCollateral].priceOracle).getValue(
            liquidV.asset()[node.borrow.indexOfCollateral].pair
        );
        // extra 2$ for gas price
        uint256 initialFunds = (node.lend.assets + 2 gwei) / latestPrice;
        // assuming diffusion swap has be carried out on collateral
        _diffuse(initialFunds, node.borrow.indexOfCollateral);
        // unlocks stable of collateral wei amount equivlavent
        lockedStables[node.lend.lender] -= node.lend.assets;
        // reconstruct a restricted node
        node.borrow.restricted = true;
        node.borrow.collateralIn -= initialFunds;
        // then try to collect interest.
        uint256 interests = calcInterestOnly(nodeId) / latestPrice;
        // sell assets equivalent on diffussion swap
        bool success = _diffuse(interests, node.borrow.indexOfCollateral);
        if (success) {
            // mint lender interest shares
            stableV.mint(node.lend.lender, calcInterestOnly(nodeId));
            // update the nodes finall collateralIn
            if (interests < node.borrow.collateralIn) node.borrow.collateralIn -= interests;
        }
        //  excess collateral will be moved to exitedPool, borrower can then scalp his remains from there
        bPool.push(node.borrow);
    }

    /**
     * @dev only devs
     * todo this function is meant to swap collateral back to defaultChoice from diffussion swap
     * todo moves the funds back to stable vault
     */
    function _diffuse(uint256 amount, uint256 selectedCollateral) internal pure returns (bool) {
        // diffussion.swap(address(selectedCollateral), defaultChoice, amount);
        amount + selectedCollateral; // just to silent warnings
        return true;
    }
}
