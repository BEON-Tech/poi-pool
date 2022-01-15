const deploymentParams = require('../deployment-params');

async function main() {

  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );
  
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Pool = await ethers.getContractFactory("PoIPoolUBI");
  console.log("Deploying PoIPoolUBI...");

  const pool = await upgrades.deployProxy(
    Pool,
    [
      deploymentParams.UBI_TOKEN_ADDRESS,
      deploymentParams.MAX_UBI_PER_RECIPIENT
    ],
    {
      initializer: 'initialize',
      unsafeAllowCustomTypes: true
    }
  );

  console.log("PoIPoolUBI deployed to:", pool.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
