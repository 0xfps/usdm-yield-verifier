
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ISP1Verifier } from "@sp1-contracts/ISP1Verifier.sol";

contract ProofManager is Ownable {
    IERC20 public immutable wUSDM;
    ISP1Verifier public immutable sp1Verifier;
    bytes32 public immutable programVKey;

    address public constant feeCollector = 0x300fE68BB87dB212b8F9BA59C39aD4a846AfAfEB;
    uint256 public constant PROOF_FEE = 1e18;
    uint256 public constant LOCK_DURATION = 1 days;

    struct Proof {
        address user;
        uint256 timestamp;
        uint256 amount;
        bool used;
    }

    mapping(bytes32 => Proof) public proofs;

    event ProofGenerated(address indexed user, bytes32 indexed proofHash, uint256 amount);
    event ProofUsed(bytes32 indexed proofHash, uint256 newBalance);

    constructor(address _wUSDM, address _sp1Verifier, bytes32 _programVKey) Ownable(msg.sender) {
        wUSDM = IERC20(_wUSDM);
        sp1Verifier = ISP1Verifier(_sp1Verifier);
        programVKey = _programVKey;
    }

    function generateProof(bytes calldata publicValues, bytes calldata proofBytes) external {
        sp1Verifier.verifyProof(programVKey, publicValues, proofBytes);

        (address user, uint256 balanceClaimed, uint256 nonce) =
            abi.decode(publicValues, (address, uint256, uint256));

        require(msg.sender == user, "Sender mismatch");

        bytes32 proofHash = keccak256(abi.encodePacked(user, balanceClaimed, nonce));
        require(proofs[proofHash].timestamp == 0, "Proof already exists");

        require(wUSDM.transferFrom(msg.sender, feeCollector, PROOF_FEE), "wUSDm payment failed");

        proofs[proofHash] = Proof({
            user: msg.sender,
            timestamp: block.timestamp,
            amount: balanceClaimed,
            used: false
        });

        emit ProofGenerated(msg.sender, proofHash, balanceClaimed);
    }

    function verifyProof(bytes32 proofHash, address claimedUser, uint256 claimedAmount) external returns (bool) {
        Proof storage p = proofs[proofHash];

        require(p.user == claimedUser, "User mismatch");
        require(p.amount == claimedAmount, "Amount mismatch");
        require(!p.used, "Proof already verified");
        require(block.timestamp >= p.timestamp + LOCK_DURATION, "Proof still locked");

        p.used = true;
        emit ProofUsed(proofHash, p.amount);
        return true;
    }

    function getProof(bytes32 proofHash) external view returns (Proof memory) {
        return proofs[proofHash];
    }
}
