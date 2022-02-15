const { expect } = require("chai");
const { upgrades } = require("hardhat");

function generateRandomId() {
    return Math.floor(Math.random() * Number.MAX_SAFE_INTEGER) + 1;
}

describe("Token contract", function () {
    
    let Contract;
    let hardhatContract;
    let governor;
    let address1;
    let address2;
    let address3;
    let address4;

    beforeEach(async function () {
        [governor, address1, address2, address3, address4] = await ethers.getSigners();
        Contract = await ethers.getContractFactory("ProofOfIntegrity");
        
        // We must deploy a proxy for this contract
        hardhatContract = await upgrades.deployProxy(
            Contract,
            [],
            {
              initializer: 'initialize',
              unsafeAllowCustomTypes: true
            }
        );
    });

    describe("Deployment", function () {
        it("Should set the right governor", async function () {
            expect(await hardhatContract.governor()).to.equal(governor.address);
        });
    });

    describe("Certifiers", function () {
        it("Should register one certifier", async function() {
            const certifierId = generateRandomId();

            await expect(hardhatContract.addCertifier("TestFirstname", "TestLastname", certifierId, address1.address))
                .to.emit(hardhatContract, "CertifiersAdded")
                .withArgs(1);

            const certifiers = await hardhatContract.getCertifiersAccounts();
            expect(certifiers.length).to.equal(1);
            expect(certifiers[0]).to.equal(address1.address);
        });

        it("Should register multiple certifiers", async function() {
            const firstNames = ["TestF2", "TestF3", "TestF4"];
            const lastNames = ["TestL2", "TestL3", "TestL4"];
            const certifierIds = [generateRandomId(), generateRandomId(), generateRandomId()];
            const addresses = [address1.address, address2.address, address3.address];

            await expect(hardhatContract.addCertifiers(firstNames, lastNames, certifierIds, addresses))
                .to.emit(hardhatContract, "CertifiersAdded")
                .withArgs(3);

            const certifiers = await hardhatContract.getCertifiersAccounts();
            expect(certifiers.length).to.equal(3);
            expect(certifiers[2]).to.equal(address3.address);
        });

        it("Should fail when trying to register multiple certifiers with an invalid number of arguments", async function() {
            const firstNames = ["TestF2", "TestF3", "TestF4"];
            const lastNames = ["TestL2", "TestL3", "TestL4"];
            const certifierIds = [generateRandomId(), generateRandomId()];
            const addresses = [address1.address, address2.address, address3.address];
            
            await expect(hardhatContract.addCertifiers(firstNames, lastNames, certifierIds, addresses))
                .to.be.revertedWith("Invalid arrays length");
        });

        it("Should confirm valid / invalid certifier data", async function() {
            const firstName = "TestFirstname";
            const lastName = "TestLastname";
            const certifierId = generateRandomId();

            await hardhatContract.addCertifier(firstName, lastName, certifierId, address1.address);

            const results = await hardhatContract.getCertifier(address1.address);
            expect(results["_certifierId"]).to.equal(certifierId);
            
            const validResult = await hardhatContract.verifyCertifier(address1.address, firstName, lastName, certifierId);
            expect(validResult).to.equal(true);

            const invalidResult = await hardhatContract.verifyCertifier(address1.address, firstName, "TestLastname2", certifierId);
            expect(invalidResult).to.equal(false);
        });

        it("Should fail if sender tries to register same certifier's wallet twice (or more)", async function() {
            const firstName = "TestFirstname";
            const lastName = "TestLastname";
            const certifierId = generateRandomId();

            await hardhatContract.addCertifier(firstName, lastName, certifierId, address1.address);
            await expect(hardhatContract.addCertifier(firstName, lastName, certifierId, address1.address))
                .to.be.revertedWith("Wallet address already in use");
        });

        it("Should allow only the governor to register certifiers", async function() {
            await expect(hardhatContract.connect(address1).addCertifier("TestFirstname2", "TestLastname2", generateRandomId(), address2.address))
                .to.be.revertedWith("The caller is not the governor.");
        });

        it("Should fail if sender tries to get or verify an unregistered certifier's wallet", async function() {
            const firstName = "TestFirstname";
            const lastName = "TestLastname";
            const certifierId = generateRandomId();

            await hardhatContract.addCertifier(firstName, lastName, certifierId, address1.address);

            const certifierData = await hardhatContract.getCertifier(address1.address);
            expect(certifierData["_certifierId"]).to.equal(certifierId);

            await expect(hardhatContract.getCertifier(address2.address))
                .to.be.revertedWith("Invalid wallet address");
        });

        it("Should confirm registered / unregistered certifier's wallet", async function() {
            const firstName = "TestFirstname";
            const lastName = "TestLastname";
            const certifierId = generateRandomId();

            await hardhatContract.addCertifier(firstName, lastName, certifierId, address1.address);

            const validResult = await hardhatContract.certifierIsRegistered(address1.address);
            expect(validResult).to.equal(true);

            const invalidResult = await hardhatContract.certifierIsRegistered(address2.address);
            await expect(invalidResult).to.equal(false);
        });
    });

    describe("Applicants", function () {
        it("Should register one applicant", async function() {
            const applicantId = generateRandomId();

            await expect(hardhatContract.addApprovedApplicant("TestFirstname", "TestLastname", applicantId, address1.address))
                .to.emit(hardhatContract, "ApplicantsAdded")
                .withArgs(1);

            const applicants = await hardhatContract.getApprovedApplicantsAccounts();
            expect(applicants.length).to.equal(1);
            expect(applicants[0]).to.equal(address1.address);
        });

        it("Should register multiple applicants", async function() {
            const firstNames = ["TestF2", "TestF3", "TestF4"];
            const lastNames = ["TestL2", "TestL3", "TestL4"];
            const applicantIds = [generateRandomId(), generateRandomId(), generateRandomId()];
            const addresses = [address1.address, address2.address, address3.address];

            await expect(hardhatContract.addApprovedApplicants(firstNames, lastNames, applicantIds, addresses))
                .to.emit(hardhatContract, "ApplicantsAdded")
                .withArgs(3);

            const applicants = await hardhatContract.getApprovedApplicantsAccounts();
            expect(applicants.length).to.equal(3);
            expect(applicants[1]).to.equal(address2.address);
        });

        it("Should fail when trying to register multiple applicants with an invalid number of arguments", async function() {
            const firstNames = ["TestF2", "TestF3", "TestF4"];
            const lastNames = ["TestL2", "TestL3", "TestL4"];
            const applicantIds = [generateRandomId(), generateRandomId(), generateRandomId()];
            const addresses = [address1.address, address2.address];

            await expect(hardhatContract.addApprovedApplicants(firstNames, lastNames, applicantIds, addresses))
                .to.be.revertedWith("Invalid arrays length");
        });

        it("Should confirm valid / invalid applicant data", async function() {
            const firstName = "TestFirstname";
            const lastName = "TestLastname";
            const applicantId = generateRandomId();

            await hardhatContract.addApprovedApplicant(firstName, lastName, applicantId, address1.address);

            const results = await hardhatContract.getApprovedApplicant(address1.address);
            expect(results["_applicantId"]).to.equal(applicantId);
            
            const validResult = await hardhatContract.verifyApprovedApplicant(address1.address, firstName, lastName, applicantId);
            expect(validResult).to.equal(true);

            const invalidResult = await hardhatContract.verifyApprovedApplicant(address1.address, "TestFirstname2", lastName, applicantId);
            expect(invalidResult).to.equal(false);
        });

        it("Should fail if sender tries to register same applicant's wallet twice (or more)", async function() {
            const firstName = "TestFirstname";
            const lastName = "TestLastname";
            const applicantId = generateRandomId();

            await hardhatContract.addApprovedApplicant(firstName, lastName, applicantId, address1.address);
            await expect(hardhatContract.addApprovedApplicant(firstName, lastName, applicantId, address1.address))
                .to.be.revertedWith("Wallet address already in use");
        });

        it("Should allow only the governor to register applicants", async function() {
            await expect(hardhatContract.connect(address1).addApprovedApplicant("TestFirstname2", "TestLastname2", generateRandomId(), address2.address))
                .to.be.revertedWith("The caller is not the governor.");
        });

        it("Should fail if sender tries to get or verify an unregistered applicant's wallet", async function() {
            const firstName = "TestFirstname";
            const lastName = "TestLastname";
            const applicantId = generateRandomId();

            await hardhatContract.addApprovedApplicant(firstName, lastName, applicantId, address1.address);

            const applicantData = await hardhatContract.getApprovedApplicant(address1.address);
            expect(applicantData["_applicantId"]).to.equal(applicantId);

            await expect(hardhatContract.getApprovedApplicant(address2.address))
                .to.be.revertedWith("Invalid wallet address");
        });

        it("Should confirm registered / unregistered applicant's wallet", async function() {
            const firstName = "TestFirstname";
            const lastName = "TestLastname";
            const applicantId = generateRandomId();

            await hardhatContract.addApprovedApplicant(firstName, lastName, applicantId, address1.address);

            const validResult = await hardhatContract.approvedApplicantIsRegistered(address1.address);
            expect(validResult).to.equal(true);

            const invalidResult = await hardhatContract.approvedApplicantIsRegistered(address2.address);
            await expect(invalidResult).to.equal(false);
        });
        
    });

    describe("Granted Applications", function () {
        it("Should register one granted application", async function() {
            await hardhatContract.addCertifier("TestCertifierFirstname", "TestCertifierLastname", generateRandomId(), address1.address);
            await hardhatContract.addApprovedApplicant("TestApplicantFirstname", "TestApplicantLastname", generateRandomId(), address2.address);

            const applicationId = generateRandomId();
            await expect(hardhatContract.addGrantedApplication(address1.address, address2.address, applicationId))
                .to.emit(hardhatContract, "ApplicationsAdded")
                .withArgs(1);

            const grantedApplications = await hardhatContract.getGrantedApplicationIds();
            expect(grantedApplications.length).to.equal(1);
            expect(grantedApplications[0]).to.equal(applicationId);
        });

        it("Should register multiple granted applications", async function() {
            await hardhatContract.addCertifier("TestCertifierFirstname", "TestCertifierLastname", generateRandomId(), address1.address);
            await hardhatContract.addApprovedApplicant("TestApplicantFirstname1", "TestApplicantLastname1", generateRandomId(), address2.address);
            await hardhatContract.addApprovedApplicant("TestApplicantFirstname2", "TestApplicantLastname2", generateRandomId(), address3.address);
            await hardhatContract.addApprovedApplicant("TestApplicantFirstname3", "TestApplicantLastname3", generateRandomId(), address4.address);

            let certifiersWallets = [address1.address, address1.address, address1.address];
            let applicantsWallets = [address2.address, address3.address, address4.address];
            let applicationIds = [generateRandomId(), generateRandomId(), generateRandomId()];
            await expect(hardhatContract.addGrantedApplications(certifiersWallets, applicantsWallets, applicationIds))
                .to.emit(hardhatContract, "ApplicationsAdded")
                .withArgs(3);

            const grantedApplications = await hardhatContract.getGrantedApplicationIds();
            expect(grantedApplications.length).to.equal(3);
            expect(grantedApplications[1]).to.equal(applicationIds[1]);
        });

        it("Should fail while trying to register granted applications using invalid addresses", async function() {
            // TODO
        });
    });

});