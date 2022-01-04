const deploymentParams = require('../deployment-params');

async function main() {

  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );
  
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Token = await ethers.getContractFactory("MockUBI");
  console.log("Deploying MUBI Coin...");

  const token = await upgrades.deployProxy(
    Token,
    [],
    {}
  );
  
  console.log("MUBI deployed to:", token.address);

  const Pool = await ethers.getContractFactory("PoIPool");
  console.log("Deploying PoIPool...");

  const pool = await upgrades.deployProxy(
    Pool,
    [
      token.address,
      deploymentParams.MAX_UBI_PER_RECIPIENT
    ],
    {
      initializer: 'initialize',
      unsafeAllowCustomTypes: true 
    }
  );

  console.log("PoIPool deployed to:", pool.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
