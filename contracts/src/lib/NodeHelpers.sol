// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../lib/Structs.sol";

library NodeHelpers {
    function approve(Pool storage self, uint256 nodeId) public {
        self.generalPool[nodeId].isPending = false;
        self.generalPool[nodeId].timeStamp = block.timestamp;
    }

    function reject(Pool storage self, uint256 nodeId) public {
        self.generalPool[nodeId].isOpen = false;
        self.generalPool[nodeId].isPending = false;
    }

    function create(
        Pool storage self,
        uint256 assets,
        uint8 choice,
        uint8 interest,
        bool approvalBased,
        uint8 collateralPercent
    ) public {
        PartialNodeL memory _new = PartialNodeL({
            lender: msg.sender,
            choiceOfStable: choice,
            interestRate: interest,
            assets: assets,
            filled: false,
            acceptingRequests: true,
            approvalBased: approvalBased,
            minCollateralPercentage: collateralPercent
        });
        self.stablePool.push(_new);
    }

    function createUnstable(
        Pool storage self,
        address receiver,
        address _collateral,
        uint256 amount,
        uint8 choice,
        uint8 interest,
        uint8 tenure,
        uint256 expectedOutput,
        bool _personalised,
        uint8[3] memory acceptedTenures
    ) public {
        PartialNodeB memory _new = PartialNodeB({
            borrower: receiver,
            collateral: _collateral,
            collateralIn: amount,
            maximumExpectedOutput: expectedOutput,
            tenure: acceptedTenures[tenure],
            indexOfCollateral: choice,
            maxPayableInterest: interest,
            restricted: false,
            personalised: _personalised
        });
        self.liquidPool.push(_new);
    }

    function fill(
        Pool storage self,
        uint8 choice,
        uint256 assets,
        uint256 nodeIdL,
        uint8 tenure,
        address collateral,
        uint256 amount,
        uint8 interest,
        uint8[3] memory acceptedTenures
    ) external returns (PartialNodeB memory) {
        PartialNodeB memory borrower = PartialNodeB({
            borrower: msg.sender,
            collateral: collateral,
            collateralIn: assets,
            maximumExpectedOutput: amount,
            tenure: acceptedTenures[tenure],
            indexOfCollateral: choice,
            maxPayableInterest: interest,
            restricted: false,
            personalised: false
        });
        self.stablePool[nodeIdL].filled = true;
        return borrower;
    }

    function fillUnstable(
        Pool storage self,
        uint8 choice,
        uint8 interest,
        uint256 assets
    ) public returns (PartialNodeL memory) {
        PartialNodeL memory lender = PartialNodeL({
            lender: msg.sender,
            choiceOfStable: choice,
            interestRate: interest,
            assets: assets,
            filled: true,
            acceptingRequests: true,
            approvalBased: false,
            minCollateralPercentage: 125
        });

        self.stablePool.push(lender);
        return lender;
    }

    function mergedPool(Pool storage self, uint256 nodeCount) public view returns (Node[] memory) {
        Node[] memory _allNodes = new Node[](nodeCount);
        for (uint256 i = 0; i < nodeCount; i++) {
            _allNodes[i] = self.generalPool[i];
        }
        return _allNodes;
    }

    function calcLoanPlusInterest(Pool storage self, uint256 nodeId) public view returns (uint256) {
        return self.generalPool[nodeId].lend.assets + calcInterestOnly(self, nodeId);
    }

    function calcInterestOnly(Pool storage self, uint256 nodeId) public view returns (uint256) {
        return (self.generalPool[nodeId].lend.assets * self.generalPool[nodeId].lend.interestRate) / 100;
    }

    function tenureExpired(Pool storage self, uint256 nodeId) public view returns (bool) {
        return block.timestamp > self.generalPool[nodeId].timeStamp + self.generalPool[nodeId].borrow.tenure * 1 days;
    }

    function forcedExit(Pool storage self, uint256 nodeId) public {
        self.generalPool[nodeId].borrow.restricted = true;
        self.generalPool[nodeId].isOpen = false;
        self.liquidPool.push(self.generalPool[nodeId].borrow);
    }

    function mergeNode(
        Pool storage self,
        PartialNodeB memory borrow,
        PartialNodeL memory lend,
        uint256 nodeCount,
        bool pending
    ) public {
        Node memory _new = Node({
            nodeId: nodeCount,
            timeStamp: pending ? 0 : block.timestamp,
            isOpen: true,
            isPending: pending,
            lend: lend,
            borrow: borrow
        });

        self.generalPool[nodeCount] = _new;
    }

    function extendDuration(Pool storage self, uint256 nodeId) public {
        self.generalPool[nodeId].borrow.tenure += 15;

        uint8 oldInterst = self.generalPool[nodeId].lend.interestRate;
        uint8 newInterest = oldInterst / uint8(self.generalPool[nodeId].borrow.tenure / 15) + oldInterst;

        (newInterest > 15)
            ? self.generalPool[nodeId].lend.interestRate = 15
            : self.generalPool[nodeId].lend.interestRate = newInterest;
    }
}
