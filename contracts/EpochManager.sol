// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

contract EpochManager {
    uint256 public immutable epochLength;
    uint256 public startBlock;
    mapping(uint256 => uint256) public epochYield;

    event NewEpoch(uint256 indexed epochId, uint256 yield);

    constructor(uint256 _epochLength) {
        epochLength = _epochLength;
        startBlock = block.number;
    }

    function getCurrentEpoch() public view returns (uint256) {
        return (block.number - startBlock) / epochLength;
    }

    function setYieldForEpoch(uint256 epochId, uint256 yieldAmount) external {
        // TODO: add access control here (e.g., onlyOperator)
        epochYield[epochId] = yieldAmount;
        emit NewEpoch(epochId, yieldAmount);
    }
}

