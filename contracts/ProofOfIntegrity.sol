// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./utils/ArrayLengthComparator.sol";

contract ProofOfIntegrity is Initializable {

  /* Events */

  event CertifiersAdded(uint256 totalAdded);
  event ApplicantsAdded(uint256 totalAdded);
  event ApplicationsAdded(uint256 totalAdded);

  /* Structs */

  struct Certifier {
    uint256 certifierId;
    uint256 registrationDate;
    bytes32 evidenceHash;
    uint256[] associatedGrantedApplicationIds;
  }

  struct Applicant {
    uint256 applicantId;
    uint256 registrationDate;
    bytes32 evidenceHash;
    uint256[] associatedGrantedApplicationIds;
  }

  struct Application {
    uint256 appointmentId;
    address certifier;
    address applicant;
    uint256 registrationDate;
    bytes32 evidenceHash;
  }

  /* Storage */

  address public governor;
  mapping(address => Certifier) public certifiers;
  mapping(address => Applicant) public approvedApplicants;
  mapping(uint256 => Application) grantedApplications;
  address[] public certifiersAccounts;
  address[] public approvedApplicantsAccounts;
  uint256[] public grantedApplicationIds;

  /// @dev Verifies that the sender has ability to modify governed parameters.
  modifier onlyByGovernor() {
    require(governor == msg.sender, "The caller is not the governor.");
    _;
  }

  /* Initializer */

  function initialize() public initializer {
    governor = msg.sender;
  }

  /** Certifiers **/

  function addCertifier(string calldata _firstname, string calldata _lastname, uint256 _databaseId, address _wallet) external onlyByGovernor {
    _addCertifier(_firstname, _lastname, _databaseId, _wallet);
    emit CertifiersAdded(1);
  }

  /**
   * @param _firstnames An array of strings with the list of certifiers' first names.
   * @param _lastnames An array of strings with the list of certifiers' last names.
   * @param _databaseIds An array of strings with the list of certifiers' database IDs.
   * @param _wallets An array of addresses with the list of certifiers' wallets.
   */
  function addCertifiers(string[] calldata _firstnames, string[] calldata _lastnames, uint256[] calldata _databaseIds, address[] calldata _wallets) external onlyByGovernor {
    ArrayLengthComparator comparator = new ArrayLengthComparator();
    require(comparator.add(_firstnames).add(_lastnames).add(_databaseIds).add(_wallets).areEqual(), "Invalid arrays length");
 
    for(uint i = 0; i < _firstnames.length; i++) {
      _addCertifier(_firstnames[i], _lastnames[i], _databaseIds[i], _wallets[i]);
    }
    emit CertifiersAdded(_firstnames.length);
  }

  function _addCertifier(string calldata _firstname, string calldata _lastname, uint256 _databaseId, address _wallet) internal onlyByGovernor {
    require(!certifierIsRegistered(_wallet), "Wallet address already in use");

    Certifier storage certifier = certifiers[_wallet];
    certifier.certifierId = _databaseId;
    certifier.registrationDate = block.timestamp;
    certifier.evidenceHash = keccak256(abi.encodePacked(_firstname, _lastname, _databaseId));
    certifiersAccounts.push(_wallet);
  }

  function getCertifiersAccounts() external view returns (address[] memory) {
    return certifiersAccounts;
  }

  function getCertifier(address _wallet) external view returns (uint256 _certifierId, uint256 _registrationDate, bytes32 _evidenceHash) {
    require(certifierIsRegistered(_wallet), "Invalid wallet address");

    _certifierId = certifiers[_wallet].certifierId;
    _registrationDate = certifiers[_wallet].registrationDate;
    _evidenceHash = certifiers[_wallet].evidenceHash;
  }

  function getCertifierApplicationIds(address _wallet) external view returns (uint256[] memory) {
    require(certifierIsRegistered(_wallet), "Invalid wallet address");

    return certifiers[_wallet].associatedGrantedApplicationIds;
  }

  function verifyCertifier(address _wallet, string calldata _firstname, string calldata _lastname, string calldata _databaseId) external view returns (bool) {
    require(certifierIsRegistered(_wallet), "Invalid wallet address");

    return certifiers[_wallet].evidenceHash == keccak256(abi.encodePacked(_firstname, _lastname, _databaseId));
  }

  function certifierIsRegistered(address _wallet) public view returns (bool) {
    return (certifiers[_wallet].evidenceHash > 0);
  }

  /** Applicants **/

  function addApprovedApplicant(string calldata _firstname, string calldata _lastname, uint256 _databaseId, address _wallet) external onlyByGovernor {
    _addApprovedApplicant(_firstname, _lastname, _databaseId, _wallet);
    emit ApplicantsAdded(1);
  }

  /**
   * @param _firstnames An array of strings with the list of applicants' first names.
   * @param _lastnames An array of strings with the list of applicants' last names.
   * @param _databaseIds An array of uint256 with the list of applicants' database IDs.
   * @param _wallets An array of addresses with the list of applicants' wallets.
   */
  function addApprovedApplicants(string[] calldata _firstnames, string[] calldata _lastnames, uint256[] calldata _databaseIds, address[] calldata _wallets) external onlyByGovernor {
    ArrayLengthComparator comparator = new ArrayLengthComparator();
    require(comparator.add(_firstnames).add(_lastnames).add(_databaseIds).add(_wallets).areEqual(), "Invalid arrays length");

    for(uint i = 0; i < _firstnames.length; i++) {
      _addApprovedApplicant(_firstnames[i], _lastnames[i], _databaseIds[i], _wallets[i]);
    }
    emit ApplicantsAdded(_firstnames.length);
  }

  function _addApprovedApplicant(string calldata _firstname, string calldata _lastname, uint256 _databaseId, address _wallet) internal onlyByGovernor {
    require(!approvedApplicantIsRegistered(_wallet), "Wallet address already in use");

    Applicant storage applicant = approvedApplicants[_wallet];
    applicant.applicantId = _databaseId;
    applicant.registrationDate = block.timestamp;
    applicant.evidenceHash = keccak256(abi.encodePacked(_firstname, _lastname, _databaseId));
    approvedApplicantsAccounts.push(_wallet);
  }

  function getApprovedApplicantsAccounts() external view returns (address[] memory) {
    return approvedApplicantsAccounts;
  }

  function getApprovedApplicant(address _wallet) external view returns (uint256 _applicantId, uint256 _registrationDate, bytes32 _evidenceHash) {
    require(approvedApplicantIsRegistered(_wallet), "Invalid wallet address");

    _applicantId = approvedApplicants[_wallet].applicantId;
    _registrationDate = approvedApplicants[_wallet].registrationDate;
    _evidenceHash = approvedApplicants[_wallet].evidenceHash;
  }

  function getApprovedApplicantApplicationIds(address _wallet) external view returns (uint256[] memory) {
    require(approvedApplicantIsRegistered(_wallet), "Invalid wallet address");

    return approvedApplicants[_wallet].associatedGrantedApplicationIds;
  }

  function verifyApprovedApplicant(address _wallet, string calldata _firstname, string calldata _lastname, string calldata _databaseId) external view returns (bool) {
    require(approvedApplicantIsRegistered(_wallet), "Invalid wallet address");

    return approvedApplicants[_wallet].evidenceHash == keccak256(abi.encodePacked(_firstname, _lastname, _databaseId));
  }

  function approvedApplicantIsRegistered(address _wallet) public view returns (bool) {
    return (approvedApplicants[_wallet].evidenceHash > 0);
  }

  /** Applications **/

  function addGrantedApplication(address _certifierWallet, address _applicantWallet, uint256 _databaseId) external onlyByGovernor {
    _addGrantedApplication(_certifierWallet, _applicantWallet, _databaseId);
    emit ApplicationsAdded(1);
  }

  function addGrantedApplications(address[] calldata _certifierWallets, address[] calldata _applicantWallets, uint256[] calldata _databaseIds) external onlyByGovernor {
    ArrayLengthComparator comparator = new ArrayLengthComparator();
    require(comparator.add(_certifierWallets).add(_applicantWallets).add(_databaseIds).areEqual(), "Invalid arrays length");

    for(uint i = 0; i < _certifierWallets.length; i++) {
      _addGrantedApplication(_certifierWallets[i], _applicantWallets[i], _databaseIds[i]);
    }
    emit ApplicationsAdded(_certifierWallets.length);
  }

  function _addGrantedApplication(address _certifierWallet, address _applicantWallet, uint256 _databaseId) internal onlyByGovernor {
    require(certifierIsRegistered(_certifierWallet), "Invalid certifier wallet address");
    require(approvedApplicantIsRegistered(_applicantWallet), "Invalid applicant wallet address");
    require(!grantedApplicationIsRegistered(_databaseId), "Application ID already in use");

    /* Store the application */
    Application storage application = grantedApplications[_databaseId];
    application.appointmentId = _databaseId;
    application.certifier = _certifierWallet;
    application.applicant = _applicantWallet;
    application.registrationDate = block.timestamp;
    application.evidenceHash = keccak256(abi.encodePacked(certifiers[_certifierWallet].evidenceHash, approvedApplicants[_applicantWallet].evidenceHash));
    grantedApplicationIds.push(_databaseId);

    /* Associate the application to the certifier */
    certifiers[_certifierWallet].associatedGrantedApplicationIds.push(_databaseId);

    /* Associate the application to the applicant */
    approvedApplicants[_applicantWallet].associatedGrantedApplicationIds.push(_databaseId);
  }

  function getGrantedApplication(uint256 _databaseId) external view returns (address _certifier, address _applicant, uint256 _registrationDate, bytes32 _evidenceHash) {
    require(grantedApplicationIsRegistered(_databaseId), "Invalid Application ID");

    _certifier = grantedApplications[_databaseId].certifier;
    _applicant = grantedApplications[_databaseId].applicant;
    _registrationDate = grantedApplications[_databaseId].registrationDate;
    _evidenceHash = grantedApplications[_databaseId].evidenceHash;
  }

  function grantedApplicationIsRegistered(uint256 _databaseId) public view returns (bool) {
    return (grantedApplications[_databaseId].evidenceHash > 0);
  }
  
}