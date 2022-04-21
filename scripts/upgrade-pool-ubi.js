const deploymentParams = require('../deployment-params');

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log('Deploying contracts with the account:', deployer.address);

  console.log('Account balance:', (await deployer.getBalance()).toString());

  const PoolUBI = await ethers.getContractFactory('PoIPoolUBI');
  console.log('Upgrading PoIPoolUBI...');

  const poolUBI = await upgrades.upgradeProxy(deploymentParams.POI_POOL_UBI_KOVAN, PoolUBI);

  console.log('PoIPoolUBI upgraded:', poolUBI.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
