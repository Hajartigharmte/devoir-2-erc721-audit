import hre from "hardhat";

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Déploiement avec le compte :", deployer.address);

  const CertificateRegistry = await hre.ethers.getContractFactory("CertificateRegistryERC721");
  const registry = await CertificateRegistry.deploy(deployer.address);

  await registry.waitForDeployment();
  const address = await registry.getAddress();

  console.log("CertificateRegistryERC721 déployé à l'adresse :", address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});