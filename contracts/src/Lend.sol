// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.17;

import "./tokens/ERC4626/vStable.sol";
import {PartialNodeL, AcceptedStables} from "./lib/ImportantStructs.sol";

contract Lend {
    StablesVault immutable stableV;

    // pool of lenders
    PartialNodeL[] lPool;

    constructor(address[5] memory stables) {
        stableV = new StablesVault(stables, "svLendEgo", "svLE");
    }

    event NewLoan(address indexed lender, address indexed stable, uint256 indexed asset, uint8 interestRate);
    event BurntPosition(address indexed burner, PartialNodeL lnode);

    function createPosition(uint256 assets, uint8 choice, uint8 interest) public {
        require(interest <= 15, "Interest reate cannot be more 15%");
        // deposit into the vault
        bool success = stableV.deposit(msg.sender, assets, choice);
        // create new position
        PartialNodeL memory new_ = PartialNodeL({
            lender: msg.sender,
            choiceOfStable: AcceptedStables(choice),
            interestRate: interest,
            assets: assets,
            filled: false,
            acceptingRequests: true
        });
        // broadcast new position
        success ? lPool.push(new_) : revert("deposit failed");
        emit NewLoan(msg.sender, stableV.asset()[choice], assets, interest);
    }

    function burnPosition(uint256 partialNodeLIdx) public returns (uint256 amount) {
        // requires only msg.sender == partialNodeL.lender
        require(msg.sender == lPool[partialNodeLIdx].lender, "Lender: you are not the lender that owns this node");
        // requires position not filled.
        require(!lPool[partialNodeLIdx].filled, "you cannot not burn this position");
        //create temp memory location
        PartialNodeL memory temp = lPool[partialNodeLIdx];
        // delete the partialnode
        _removeItemFromPool(partialNodeLIdx);
        // transfer stable from vault to lender
        amount = stableV.withdraw(msg.sender, temp.assets, msg.sender, msg.sender, uint(temp.choiceOfStable));
        emit BurntPosition(msg.sender, temp);
    }

    function getAllLenders() public view returns (PartialNodeL[] memory) {
        return lPool;
    }

    function _removeItemFromPool(uint256 index) internal {
        require(index < lPool.length, "unable to remove");
        lPool[index] = lPool[lPool.length - 1];
        lPool.pop();
    }

    function getStableVaultAddress() public view returns (address) {
        return address(stableV);
    }
}
