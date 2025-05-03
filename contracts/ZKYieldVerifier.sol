// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "./interfaces/IZKYieldVerifier.sol";

contract ZKYieldVerifier is IZKYieldVerifier {
    mapping(address => mapping(uint256 => uint256)) public verifiedYields;
    mapping(address => mapping(uint256 => bool)) public proofUsed;

    event ProofSubmitted(address indexed user, uint256 indexed epoch, uint256 yield);
    event ProofInvalidated(address indexed user, uint256 indexed epoch);

    function submitProof(bytes calldata zkProof) external override returns (bool) {
        (address user, uint256 epoch, uint256 yieldAmount) = abi.decode(zkProof, (address, uint256, uint256));
        require(!proofUsed[user][epoch], "Proof already used");
        // TODO: add real SP1 verification here
        verifiedYields[user][epoch] = yieldAmount;
        proofUsed[user][epoch] = true;
        emit ProofSubmitted(user, epoch, yieldAmount);
        return true;
    }

    function getVerifiedYield(address user, uint256 epoch) external view override returns (uint256) {
        return verifiedYields[user][epoch];
    }

    function invalidateProof(address user, uint256 epoch) external override {
        proofUsed[user][epoch] = true;
        emit ProofInvalidated(user, epoch);
    }
}

