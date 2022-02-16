const deploymentParams = require('../deployment-params');

async function main() {

  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );
  
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const ProofOfIntegrity = await ethers.getContractFactory("ProofOfIntegrity");
  console.log("Deploying ProofOfIntegrity...");

  const poiContract = await upgrades.deployProxy(
    ProofOfIntegrity,
    [],
    {
      initializer: 'initialize',
      unsafeAllowCustomTypes: true
    }
  );

  console.log("ProofOfIntegrity deployed to:", poiContract.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
