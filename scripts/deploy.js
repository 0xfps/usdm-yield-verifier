async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying from:", deployer.address);

  const EpochManager = await ethers.getContractFactory("EpochManager");
  const epochManager = await EpochManager.deploy(600);
  await epochManager.deployed();
  console.log("EpochManager deployed to:", epochManager.address);

  const USDM = await ethers.getContractFactory("MockUSDM");
  const usdm = await USDM.deploy();
  await usdm.deployed();
  console.log("MockUSDM deployed to:", usdm.address);

  const Vault = await ethers.getContractFactory("wUSDmVault");
  const vault = await Vault.deploy(usdm.address, epochManager.address);
  await vault.deployed();
  console.log("Vault deployed to:", vault.address);

  const Verifier = await ethers.getContractFactory("ZKYieldVerifier");
  const verifier = await Verifier.deploy();
  await verifier.deployed();
  console.log("Verifier deployed to:", verifier.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

