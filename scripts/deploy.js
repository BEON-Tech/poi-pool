const deploymentParams = require('../deployment-params');

async function main() {

  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );
  
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const PoolUBI = await ethers.getContractFactory("PoIPoolUBI");
  console.log("Deploying PoIPoolUBI...");

  const poolUBI = await upgrades.deployProxy(
    PoolUBI,
    [
      deploymentParams.UBI_TOKEN_ADDRESS,
      deploymentParams.MAX_UBI_PER_RECIPIENT
    ],
    {
      initializer: 'initialize',
      unsafeAllowCustomTypes: true
    }
  );

  console.log("PoIPoolUBI deployed to:", poolUBI.address);

  const PoolERC20 = await ethers.getContractFactory("PoIPoolERC20");
  console.log("Deploying PoolERC20...");

  const poolERC20 = await upgrades.deployProxy(
    PoolERC20,
    [],
    {
      initializer: 'initialize',
      unsafeAllowCustomTypes: true
    }
  );

  console.log("PoolERC20 deployed to:", poolERC20.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
