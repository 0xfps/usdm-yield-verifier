const hre = require("hardhat");
const fs = require("fs");

async function main() {
  const [signer] = await hre.ethers.getSigners();

  const verifierAddress = "0xc7e561B77F88B43a434FA76a7ea5CACC78779e11"; // Your deployed verifier
  const verifier = await hre.ethers.getContractAt("ZKYieldVerifier", verifierAddress);

  const raw = fs.readFileSync("prover/output.json");
  const { user, epoch, yield_entitlement } = JSON.parse(raw);

  const proof = hre.ethers.utils.defaultAbiCoder.encode(
    ["address", "uint256", "uint256"],
    ["0x" + Buffer.from(user).toString("hex"), epoch, yield_entitlement]
  );

  const tx = await verifier.submitProof(proof);
  console.log("Submitting proof...");
  const receipt = await tx.wait();
  console.log("✅ Proof submitted in txn:", receipt.transactionHash);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

