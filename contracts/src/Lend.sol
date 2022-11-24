// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.17;

import "./tokens/ERC4626/vStable.sol";

contract Lend {
    StablesVault immutable stableV;

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
    }

    // pool of lenders
    PartialNodeL[] lPool;

    constructor(address[5] memory stables) {
        stableV = new StablesVault(stables, "svLendEgo", "svLE");
    }

    event NewLoan(address lender, address stable, uint256 asset, uint8 interestRate);

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
            filled: false
        });
        // broadcast new position
        success ? lPool.push(new_) : revert("deposit failed");
        emit NewLoan(msg.sender, stableV.asset()[choice], assets, interest);
    }

    function burnPosition(uint256 partialNodeLIdx) public {
        // requires only msg.sender == partialNodeL.lender
        require(msg.sender == lPool[partialNodeLIdx].lender, "Lender: you are not the lender that owns this node");
        // requires position not filled.
        require(lPool[partialNodeLIdx].filled == false, "you cannot not burn this position");
        // delete the partialnode
        _removeItemFromPool(partialNodeLIdx);
        // transfer stable from vault to lender
        stableV.withdraw(
            msg.sender,
            lPool[partialNodeLIdx].assets,
            msg.sender,
            msg.sender,
            uint(lPool[partialNodeLIdx].choiceOfStable)
        );
    }

    function _removeItemFromPool(uint256 index) internal {
        require(lPool.length > 0 && lPool.length <= index, "unable to remove");
        lPool[index] = lPool[lPool.length - 1];
        lPool.pop();
    }
}
