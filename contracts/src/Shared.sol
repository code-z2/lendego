// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./lib/NodeHelpers.sol";
import {PartialNodeL, PartialNodeB, Node, Pool} from "./lib/Structs.sol";

contract SharedStorage {
    using NodeHelpers for Pool;
    Pool internal pools;

    mapping(address => uint256) internal lockedStakes;
    mapping(address => uint256) internal points;

    uint8[3] internal acceptedTenures = [30, 60, 90];
    uint256 public nodeCount;
    uint8 internal immutable _defaultChoice = 0;

    function getAllLenders() public view returns (PartialNodeL[] memory) {
        return pools.stablePool;
    }

    function getAllBorrowers() public view returns (PartialNodeB[] memory) {
        return pools.liquidPool;
    }

    function getAllPositions() public view returns (Node[] memory) {
        return pools.mergedPool(nodeCount);
    }

    function getPoints() public view returns (uint256) {
        return points[msg.sender];
    }

    function getPoints(address user) public view returns (uint256) {
        return points[user];
    }
}
