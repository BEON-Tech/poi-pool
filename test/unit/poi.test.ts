import chai, { expect } from 'chai';
import { ethers } from 'hardhat';
import * as evm from '../helpers/evm';
import * as helpers from '../helpers/helpers';
import { ProofOfIntegrity, ProofOfIntegrity__factory } from '@typechain';
import { FakeContract, MockContract, MockContractFactory, smock } from '@defi-wonderland/smock';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

chai.use(smock.matchers);
describe('Token POI', function () {

  // Wallets
  let deployer: SignerWithAddress;
  let address1: SignerWithAddress;
  let address2: SignerWithAddress;
  let address3: SignerWithAddress;
  let address4: SignerWithAddress;

  // POI
  let POI: MockContract<ProofOfIntegrity>;
  let POIFactory: MockContractFactory<ProofOfIntegrity__factory>;

  // Setup
  let snapshotId: string;
 
  before(async () => {
    [deployer, address1, address2, address3, address4] = await ethers.getSigners();

    POIFactory = await smock.mock<ProofOfIntegrity__factory>('ProofOfIntegrity');
    POI = await POIFactory.connect(deployer).deploy();
    await POI.setVariable('governor', deployer.address);

    snapshotId = await evm.snapshot.take();
  });

  this.beforeEach(async () => {
    await evm.snapshot.revert(snapshotId);
  });

  describe('Deployment', function () {
    it('Should set the right deployer', async function () {
      expect(await POI.governor()).to.equal(deployer.address);
    });
  });

  describe('Certifiers', function () {
    it('Should register one certifier', async function () {
      const certifierId = helpers.generateRandomId();

      await expect(POI.addCertifier('TestFirstname', 'TestLastname', certifierId, address1.address))
        .to.emit(POI, 'CertifiersAdded')
        .withArgs(1);

      const certifiers = await POI.getCertifiersAccounts();
      expect(certifiers.length).to.equal(1);
      expect(certifiers[0]).to.equal(address1.address);
    });

    it('Should register multiple certifiers', async function () {
      const firstNames = ['TestF2', 'TestF3', 'TestF4'];
      const lastNames = ['TestL2', 'TestL3', 'TestL4'];
      const certifierIds = [helpers.generateRandomId(), helpers.generateRandomId(), helpers.generateRandomId()];
      const addresses = [address1.address, address2.address, address3.address];

      await expect(POI.addCertifiers(firstNames, lastNames, certifierIds, addresses))
        .to.emit(POI, 'CertifiersAdded')
        .withArgs(3);

      const certifiers = await POI.getCertifiersAccounts();
      expect(certifiers.length).to.equal(3);
      expect(certifiers[2]).to.equal(address3.address);
    });

    it('Should fail when trying to register multiple certifiers with an invalid number of arguments', async function () {
      const firstNames = ['TestF2', 'TestF3', 'TestF4'];
      const lastNames = ['TestL2', 'TestL3', 'TestL4'];
      const certifierIds = [helpers.generateRandomId(), helpers.generateRandomId()];
      const addresses = [address1.address, address2.address, address3.address];

      await expect(POI.addCertifiers(firstNames, lastNames, certifierIds, addresses)).to.be.revertedWith('Invalid arrays length');
    });

    it('Should confirm valid / invalid certifier data', async function () {
      const firstName = 'TestFirstname';
      const lastName = 'TestLastname';
      const certifierId = helpers.generateRandomId();

      await POI.addCertifier(firstName, lastName, certifierId, address1.address);

      const results = await POI.getCertifier(address1.address);
      expect(results['_certifierId']).to.equal(certifierId);

      const validResult = await POI.verifyCertifier(address1.address, firstName, lastName, certifierId);
      expect(validResult).to.equal(true);

      const invalidResult = await POI.verifyCertifier(address1.address, firstName, 'TestLastname2', certifierId);
      expect(invalidResult).to.equal(false);
    });

    it("Should fail if sender tries to register same certifier's wallet twice (or more)", async function () {
      const firstName = 'TestFirstname';
      const lastName = 'TestLastname';
      const certifierId = helpers.generateRandomId();

      await POI.addCertifier(firstName, lastName, certifierId, address1.address);
      await expect(POI.addCertifier(firstName, lastName, certifierId, address1.address)).to.be.revertedWith(
        'Wallet address already in use'
      );
    });

    it('Should allow only the deployer to register certifiers', async function () {
      await expect(
        POI.connect(address1).addCertifier('TestFirstname2', 'TestLastname2', helpers.generateRandomId(), address2.address)
      ).to.be.revertedWith('The caller is not the governor.');
    });

    it("Should fail if sender tries to get or verify an unregistered certifier's wallet", async function () {
      const firstName = 'TestFirstname';
      const lastName = 'TestLastname';
      const certifierId = helpers.generateRandomId();

      await POI.addCertifier(firstName, lastName, certifierId, address1.address);

      const certifierData = await POI.getCertifier(address1.address);
      expect(certifierData['_certifierId']).to.equal(certifierId);

      await expect(POI.getCertifier(address2.address)).to.be.revertedWith('Invalid wallet address');
    });

    it("Should confirm registered / unregistered certifier's wallet", async function () {
      const firstName = 'TestFirstname';
      const lastName = 'TestLastname';
      const certifierId = helpers.generateRandomId();

      await POI.addCertifier(firstName, lastName, certifierId, address1.address);

      const validResult = await POI.certifierIsRegistered(address1.address);
      expect(validResult).to.equal(true);

      const invalidResult = await POI.certifierIsRegistered(address2.address);
      await expect(invalidResult).to.equal(false);
    });
  });

  describe('Applicants', function () {
    it('Should register one applicant', async function () {
      const applicantId = helpers.generateRandomId();

      await expect(POI.addApprovedApplicant('TestFirstname', 'TestLastname', applicantId, address1.address))
        .to.emit(POI, 'ApplicantsAdded')
        .withArgs(1);

      const applicants = await POI.getApprovedApplicantsAccounts();
      expect(applicants.length).to.equal(1);
      expect(applicants[0]).to.equal(address1.address);
    });

    it('Should register multiple applicants', async function () {
      const firstNames = ['TestF2', 'TestF3', 'TestF4'];
      const lastNames = ['TestL2', 'TestL3', 'TestL4'];
      const applicantIds = [helpers.generateRandomId(), helpers.generateRandomId(), helpers.generateRandomId()];
      const addresses = [address1.address, address2.address, address3.address];

      await expect(POI.addApprovedApplicants(firstNames, lastNames, applicantIds, addresses))
        .to.emit(POI, 'ApplicantsAdded')
        .withArgs(3);

      const applicants = await POI.getApprovedApplicantsAccounts();
      expect(applicants.length).to.equal(3);
      expect(applicants[1]).to.equal(address2.address);
    });

    it('Should fail when trying to register multiple applicants with an invalid number of arguments', async function () {
      const firstNames = ['TestF2', 'TestF3', 'TestF4'];
      const lastNames = ['TestL2', 'TestL3', 'TestL4'];
      const applicantIds = [helpers.generateRandomId(), helpers.generateRandomId(), helpers.generateRandomId()];
      const addresses = [address1.address, address2.address];

      await expect(POI.addApprovedApplicants(firstNames, lastNames, applicantIds, addresses)).to.be.revertedWith(
        'Invalid arrays length'
      );
    });

    it('Should confirm valid / invalid applicant data', async function () {
      const firstName = 'TestFirstname';
      const lastName = 'TestLastname';
      const applicantId = helpers.generateRandomId();

      await POI.addApprovedApplicant(firstName, lastName, applicantId, address1.address);

      const results = await POI.getApprovedApplicant(address1.address);
      expect(results['_applicantId']).to.equal(applicantId);

      const validResult = await POI.verifyApprovedApplicant(address1.address, firstName, lastName, applicantId);
      expect(validResult).to.equal(true);

      const invalidResult = await POI.verifyApprovedApplicant(address1.address, 'TestFirstname2', lastName, applicantId);
      expect(invalidResult).to.equal(false);
    });

    it("Should fail if sender tries to register same applicant's wallet twice (or more)", async function () {
      const firstName = 'TestFirstname';
      const lastName = 'TestLastname';
      const applicantId = helpers.generateRandomId();

      await POI.addApprovedApplicant(firstName, lastName, applicantId, address1.address);
      await expect(POI.addApprovedApplicant(firstName, lastName, applicantId, address1.address)).to.be.revertedWith(
        'Wallet address already in use'
      );
    });

    it('Should allow only the deployer to register applicants', async function () {
      await expect(
        POI.connect(address1).addApprovedApplicant('TestFirstname2', 'TestLastname2', helpers.generateRandomId(), address2.address)
      ).to.be.revertedWith('The caller is not the governor.');
    });

    it("Should fail if sender tries to get or verify an unregistered applicant's wallet", async function () {
      const firstName = 'TestFirstname';
      const lastName = 'TestLastname';
      const applicantId = helpers.generateRandomId();

      await POI.addApprovedApplicant(firstName, lastName, applicantId, address1.address);

      const applicantData = await POI.getApprovedApplicant(address1.address);
      expect(applicantData['_applicantId']).to.equal(applicantId);

      await expect(POI.getApprovedApplicant(address2.address)).to.be.revertedWith('Invalid wallet address');
    });

    it("Should confirm registered / unregistered applicant's wallet", async function () {
      const firstName = 'TestFirstname';
      const lastName = 'TestLastname';
      const applicantId = helpers.generateRandomId();

      await POI.addApprovedApplicant(firstName, lastName, applicantId, address1.address);

      const validResult = await POI.approvedApplicantIsRegistered(address1.address);
      expect(validResult).to.equal(true);

      const invalidResult = await POI.approvedApplicantIsRegistered(address2.address);
      await expect(invalidResult).to.equal(false);
    });
  });

  describe('Granted Applications', function () {
    it('Should register one granted application', async function () {
      await POI.addCertifier('TestCertifierFirstname', 'TestCertifierLastname', helpers.generateRandomId(), address1.address);
      await POI.addApprovedApplicant('TestApplicantFirstname', 'TestApplicantLastname', helpers.generateRandomId(), address2.address);

      const applicationId = helpers.generateRandomId();
      await expect(POI.addGrantedApplication(address1.address, address2.address, applicationId))
        .to.emit(POI, 'ApplicationsAdded')
        .withArgs(1);

      const grantedApplications = await POI.getGrantedApplicationIds();
      expect(grantedApplications.length).to.equal(1);
      expect(grantedApplications[0]).to.equal(applicationId);
    });

    it('Should register multiple granted applications', async function () {
      await POI.addCertifier('TestCertifierFirstname', 'TestCertifierLastname', helpers.generateRandomId(), address1.address);
      await POI.addApprovedApplicant('TestApplicantFirstname1', 'TestApplicantLastname1', helpers.generateRandomId(), address2.address);
      await POI.addApprovedApplicant('TestApplicantFirstname2', 'TestApplicantLastname2', helpers.generateRandomId(), address3.address);
      await POI.addApprovedApplicant('TestApplicantFirstname3', 'TestApplicantLastname3', helpers.generateRandomId(), address4.address);

      let certifiersWallets = [address1.address, address1.address, address1.address];
      let applicantsWallets = [address2.address, address3.address, address4.address];
      let applicationIds = [helpers.generateRandomId(), helpers.generateRandomId(), helpers.generateRandomId()];
      await expect(POI.addGrantedApplications(certifiersWallets, applicantsWallets, applicationIds))
        .to.emit(POI, 'ApplicationsAdded')
        .withArgs(3);

      const grantedApplications = await POI.getGrantedApplicationIds();
      expect(grantedApplications.length).to.equal(3);
      expect(grantedApplications[1]).to.equal(applicationIds[1]);
    });

    it('Should fail while trying to register a granted application using invalid addresses', async function () {
      await POI.addCertifier('TestCertifierFirstname', 'TestCertifierLastname', helpers.generateRandomId(), address1.address);
      await POI.addApprovedApplicant('TestApplicantFirstname', 'TestApplicantLastname', helpers.generateRandomId(), address2.address);

      await expect(POI.addGrantedApplication(address3.address, address2.address, helpers.generateRandomId())).to.be.revertedWith(
        'Invalid certifier wallet address'
      );

      await expect(POI.addGrantedApplication(address1.address, address4.address, helpers.generateRandomId())).to.be.revertedWith(
        'Invalid applicant wallet address'
      );
    });

    it('Should fail while trying to register a granted application with the same application ID twice', async function () {
      await POI.addCertifier('TestCertifierFirstname', 'TestCertifierLastname', helpers.generateRandomId(), address1.address);
      await POI.addApprovedApplicant('TestApplicantFirstname', 'TestApplicantLastname', helpers.generateRandomId(), address2.address);

      const applicationId = helpers.generateRandomId();
      POI.addGrantedApplication(address1.address, address2.address, applicationId);

      await expect(POI.addGrantedApplication(address1.address, address2.address, applicationId)).to.be.revertedWith(
        'Application ID already in use'
      );
    });

    it('Should confirm the applications assigned to certifiers and applicants', async function () {
      await POI.addCertifier('TestCertifierFirstname', 'TestCertifierLastname', helpers.generateRandomId(), address1.address);
      await POI.addApprovedApplicant('TestApplicantFirstname1', 'TestApplicantLastname1', helpers.generateRandomId(), address2.address);
      await POI.addApprovedApplicant('TestApplicantFirstname2', 'TestApplicantLastname2', helpers.generateRandomId(), address3.address);

      const certifiersWallets = [address1.address, address1.address];
      const applicantsWallets = [address2.address, address3.address];
      const applicationIds = [helpers.generateRandomId(), helpers.generateRandomId()];
      POI.addGrantedApplications(certifiersWallets, applicantsWallets, applicationIds);

      const certifierApplicationIds = await POI.getCertifierApplicationIds(address1.address);
      expect(certifierApplicationIds.length).to.equal(2);
      expect(certifierApplicationIds[0].toString()).to.equal(applicationIds[0].toString());
      expect(certifierApplicationIds[1].toString()).to.equal(applicationIds[1].toString());

      const firstApplicantApplicationIds = await POI.getApprovedApplicantApplicationIds(address2.address);
      expect(firstApplicantApplicationIds.length).to.equal(1);
      expect(firstApplicantApplicationIds[0].toString()).to.equal(applicationIds[0].toString());

      const secondApplicantApplicationIds = await POI.getApprovedApplicantApplicationIds(address3.address);
      expect(secondApplicantApplicationIds.length).to.equal(1);
      expect(secondApplicantApplicationIds[0].toString()).to.equal(applicationIds[1].toString());
    });
  });
});
