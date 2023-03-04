// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./tokens/ERC4626/Entrypoint.sol";
import "./chainlink/PriceFeedConsumer.sol";
import "./utils/Diffuse.sol";

import {PartialNodeL, PartialNodeB, Node, Tokens} from "./lib/Structs.sol";

contract SharedStorage {
    PartialNodeL[] internal stablePool;
    PartialNodeB[] internal liquidPool;

    mapping(uint256 => Node) internal generalPool;
    mapping(address => uint256) internal lockedStakes;
    mapping(address => uint256) internal points;

    uint8[3] internal acceptedTenures = [30, 60, 90];

    VaultsEntrypointV1 internal entrypoint;
    PriceFeedConsumer internal oracle;
    Diffuse internal diffuser;

    uint256 public nodeCount;
    uint8 internal _defaultChoice;

    constructor(address[5] memory initialUnderlyings, address[3] memory diffuserParams) {
        entrypoint = new VaultsEntrypointV1(initialUnderlyings, address(this), msg.sender);
        oracle = new PriceFeedConsumer();
        diffuser = new Diffuse(diffuserParams[0], diffuserParams[1], diffuserParams[2]);
    }

    function getEntrypoint() public view returns (address) {
        return address(entrypoint);
    }

    function getOracle() public view returns (address) {
        return address(oracle);
    }

    function getDiffuser() public view returns (address) {
        return address(diffuser);
    }

    function getDefaultChoice() public view returns (uint8) {
        return _defaultChoice;
    }

    function getAllLenders() public view returns (PartialNodeL[] memory) {
        return stablePool;
    }

    function getAllBorrowers() public view returns (PartialNodeB[] memory) {
        return liquidPool;
    }

    function getAllPositions() public view returns (Node[] memory) {
        Node[] memory allNodes = new Node[](nodeCount);
        for (uint256 i = 0; i < nodeCount; i++) {
            allNodes[i] = generalPool[i];
        }
        return allNodes;
    }

    function getPoints() public view returns (uint256) {
        return points[msg.sender];
    }

    function getPoints(address user) public view returns (uint256) {
        return points[user];
    }
}
