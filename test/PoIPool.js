const { default: BigNumber } = require("bignumber.js");
const { expect } = require("chai");
const deploymentParams = require('../deployment-params');
const moment = require("moment");
const { network, upgrades } = require("hardhat");

let accounts;
let delegateToPool;

/**
 @summary Tests for PoIPool.sol
*/
contract('PoIPool.sol', accounts => {
    before(async () => {
        accounts = await ethers.getSigners();

        [_addresses, mockProofOfHumanity] = await Promise.all([
            Promise.all(accounts.map((account) => account.getAddress())),
            waffle.deployMockContract(
                accounts[0],
                require("../artifacts/contracts/MockUBI.sol/MockUBI.json").abi
            )
        ]);

        addresses = _addresses;

        MockUBICoin = await ethers.getContractFactory("MockUBI");

        ubi = await upgrades.deployProxy(MockUBICoin,
            [deploymentParams.MAX_UBI_PER_RECIPIENT],
            { initializer: 'initialize', unsafeAllowCustomTypes: true }
        );

        ubi = await upgrades.upgradeProxy(ubi.address, UBICoin);
        await ubi.deployed();


        // For testing purposes only, we define a max of 10 streams allowed
        await ubi.setMaxStreamsAllowed(10);

        altProofOfHumanity = await waffle.deployMockContract(accounts[0], require("../artifacts/contracts/UBI.sol/IProofOfHumanity.json").abi);

        // Global contract variables
        accruedPerSecond = BigNumber((await ubi.accruedPerSecond()).toString());
        maxStreamsAllowed = BigNumber((await ubi.maxStreamsAllowed()).toString());

        // Set zero address as not registered
        setSubmissionIsRegistered(ethers.constants.AddressZero, false);

        const deletageUBIFactory = await ethers.getContractFactory("DelegateUBIToPool");
        deletageUBI = await upgrades.deployProxy(deletageUBIFactory, [mockProofOfHumanity.address, ubi.address]);
        await deletageUBI.deployed();
    });

    /*const ubiCoinTests = () => {
        it("happy path - return a value previously initialized.", async () => {
            // Check that the value passed to the constructor is set.
            expect((await ubi.accruedPerSecond()).toString()).to.equal(deploymentParams.ACCRUED_PER_SECOND.toString());
        });
    };

    describe('UBI Coin and Proof of Humanity', ubiCoinTests);*/

    /*describe('#delegateToPool', () => {
        it("require fail - Percentage is zero", async () => {
            await setSubmissionIsRegistered(addresses[0], true);
            await expect(deletageUBI.delegateToPool(addresses[1], 0))
                .to.be.revertedWith("Percentage is zero");
        });
    });*/
});