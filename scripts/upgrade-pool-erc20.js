const deploymentParams = require('../deployment-params');

async function main() {

  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const PoolERC20 = await ethers.getContractFactory("PoIPoolERC20");
  console.log("Upgrading PoIPoolERC20...");

  const poolERC20 = await upgrades.upgradeProxy(deploymentParams.POI_POOL_ERC20_KOVAN, PoolERC20); 

  console.log("PoIPoolERC20 upgraded:", poolERC20.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
