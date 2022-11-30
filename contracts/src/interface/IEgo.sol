// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.17;

interface IEgo {
    function fillPosition(
        uint128 selectedCollateral,
        uint256 collateralIn_,
        uint256 partialNodeLIdx,
        uint256 tenure
    ) external;

    function fillUnstablePosition(uint256 partialNodeBIdx) external;

    function exitLenderFromPosition(uint256 nodeId) external;

    function exitBorrowerFromPosition(uint256 nodeId, address reciever) external;

    function calcLoanPlusInterest(uint256 nodeId) external view;

    function calcInterestOnly(uint256 nodeId) external view;

    function extendLoanDuration(uint256 nodeId) external;

    function getAllPositions() external view;

    function deactivateLenderNode(uint256 partialNodeLIdx) external;

    function withdraw(uint256 assets, address receiver, uint8 choice) external;

    function redeem(uint256 shares, address receiver, uint8 choice) external;
}
