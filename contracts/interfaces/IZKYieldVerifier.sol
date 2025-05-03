// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IZKYieldVerifier {
    function submitProof(bytes calldata zkProof) external returns (bool);
    function getVerifiedYield(address user, uint256 epoch) external view returns (uint256);
    function invalidateProof(address user, uint256 epoch) external;
}

