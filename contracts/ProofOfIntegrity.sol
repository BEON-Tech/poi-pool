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
  mapping(uint256 => Application) public grantedApplications;
  address[] private certifiersAccounts;
  address[] private approvedApplicantsAccounts;
  uint256[] private grantedApplicationIds;

  /** @dev Verifies that the sender has ability to modify governed parameters.
   */ 
  modifier onlyByGovernor() {
    require(governor == msg.sender, "The caller is not the governor.");
    _;
  }

  /* Initializer */
  
  function initialize() public initializer {
    governor = msg.sender;
  }

  /** Certifiers **/

  /** @dev Adds a certifier. Creates an evidence hash based on the given data (it doesn't store them).
   * @param _firstname Certifiers's first name.
   * @param _lastname Certifiers's last name.
   * @param _databaseId Record id for the certifier in the database.
   * @param _wallet Address of the Certifier's wallet.
   */
  function addCertifier(string calldata _firstname, string calldata _lastname, uint256 _databaseId, address _wallet) external onlyByGovernor {
    _addCertifier(_firstname, _lastname, _databaseId, _wallet);
    emit CertifiersAdded(1);
  }

  /** @dev Adds multiple certifiers within the same transaction. Creates an evidence hash based on the given data (it doesn't store them).
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

  /** @dev Returns the list of addresses of the added certifiers.
   */
  function getCertifiersAccounts() external view returns (address[] memory) {
    return certifiersAccounts;
  }

  /** @dev Returns information about the registered certifier.
   * @param _wallet Certifier's wallet address.
   * @return _certifierId Certifier's database ID.
   * @return _registrationDate Block Timestamp when the register was added to the smart contract.
   * @return _evidenceHash The evidence hash that validates the certifier's personal information.
   */
  function getCertifier(address _wallet) external view returns (uint256 _certifierId, uint256 _registrationDate, bytes32 _evidenceHash) {
    require(certifierIsRegistered(_wallet), "Invalid wallet address");

    _certifierId = certifiers[_wallet].certifierId;
    _registrationDate = certifiers[_wallet].registrationDate;
    _evidenceHash = certifiers[_wallet].evidenceHash;
  }
  
  /** @dev Returns an array of application IDs associated with the given certifier.
   * @param _wallet Certifier's wallet address.
   */
  function getCertifierApplicationIds(address _wallet) external view returns (uint256[] memory) {
    require(certifierIsRegistered(_wallet), "Invalid wallet address");

    return certifiers[_wallet].associatedGrantedApplicationIds;
  }

  /** @dev Returns true if the given data for the given certifier matches the stored evidence hash. Otherwise, returns false.
   * @param _wallet Certifier's wallet address.
   * @param _firstname Certifiers's first name.
   * @param _lastname Certifiers's last name.
   * @param _databaseId Record id for the certifier in the database.
   */
  function verifyCertifier(address _wallet, string calldata _firstname, string calldata _lastname, uint256 _databaseId) external view returns (bool) {
    require(certifierIsRegistered(_wallet), "Invalid wallet address");

    return certifiers[_wallet].evidenceHash == keccak256(abi.encodePacked(_firstname, _lastname, _databaseId));
  }

  /** @dev Returns true if the certifier's wallet address is registered. Otherwise, returns false.
   * @param _wallet Certifier's wallet address.
   */
  function certifierIsRegistered(address _wallet) public view returns (bool) {
    return (certifiers[_wallet].evidenceHash > 0);
  }

  /** Applicants **/

  /** @dev Adds an approved applicant. Creates an evidence hash based on the given data (it doesn't store them).
   * @param _firstname Applicant's first name.
   * @param _lastname Applicant's last name.
   * @param _databaseId Record id for the applicant in the database.
   * @param _wallet Address of the Applicant's wallet.
   */
  function addApprovedApplicant(string calldata _firstname, string calldata _lastname, uint256 _databaseId, address _wallet) external onlyByGovernor {
    _addApprovedApplicant(_firstname, _lastname, _databaseId, _wallet);
    emit ApplicantsAdded(1);
  }

  /** @dev Adds multiple approved applicants within the same transaction. Creates an evidence hash based on the given data (it doesn't store them).
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

  /** @dev Returns the list of addresses of the added applicants.
   */
  function getApprovedApplicantsAccounts() external view returns (address[] memory) {
    return approvedApplicantsAccounts;
  }
  
  /** @dev Returns information about the registered approved applicant.
   * @param _wallet Applicant's wallet address.
   * @return _applicantId Applicant's database ID.
   * @return _registrationDate Block Timestamp when the register was added to the smart contract.
   * @return _evidenceHash The evidence hash that validates the applicant's personal information.
   */
  function getApprovedApplicant(address _wallet) external view returns (uint256 _applicantId, uint256 _registrationDate, bytes32 _evidenceHash) {
    require(approvedApplicantIsRegistered(_wallet), "Invalid wallet address");

    _applicantId = approvedApplicants[_wallet].applicantId;
    _registrationDate = approvedApplicants[_wallet].registrationDate;
    _evidenceHash = approvedApplicants[_wallet].evidenceHash;
  }

  /** @dev Returns an array of application IDs associated with the given applicant.
   * @param _wallet Applicant's wallet address.
   */
  function getApprovedApplicantApplicationIds(address _wallet) external view returns (uint256[] memory) {
    require(approvedApplicantIsRegistered(_wallet), "Invalid wallet address");

    return approvedApplicants[_wallet].associatedGrantedApplicationIds;
  }

  /** @dev Returns true if the given data for the given applicant matches the stored evidence hash. Otherwise, returns false.
   * @param _wallet Applicant's wallet address.
   * @param _firstname Applicant's first name.
   * @param _lastname Applicant's last name.
   * @param _databaseId Record id for the applicant in the database.
   */
  function verifyApprovedApplicant(address _wallet, string calldata _firstname, string calldata _lastname, uint256 _databaseId) external view returns (bool) {
    require(approvedApplicantIsRegistered(_wallet), "Invalid wallet address");

    return approvedApplicants[_wallet].evidenceHash == keccak256(abi.encodePacked(_firstname, _lastname, _databaseId));
  }

  /** @dev Returns true if the applicant's wallet address is registered. Otherwise, returns false.
   * @param _wallet Applicant's wallet address.
   */
  function approvedApplicantIsRegistered(address _wallet) public view returns (bool) {
    return (approvedApplicants[_wallet].evidenceHash > 0);
  }

  /** Applications **/

  /** @dev Adds a register of the granted applicantion. It associates the certifier with the applicant.
   * @param _certifierWallet Certifiers's wallet address.
   * @param _applicantWallet Applicant's wallet address.
   * @param _databaseId Database ID of the granted application.
   */
  function addGrantedApplication(address _certifierWallet, address _applicantWallet, uint256 _databaseId) external onlyByGovernor {
    _addGrantedApplication(_certifierWallet, _applicantWallet, _databaseId);
    emit ApplicationsAdded(1);
  }

  /** @dev Adds multiple registers using the information of different granted applications.
   * @param _certifierWallets An array of addresses with the list of certifiers' wallets.
   * @param _applicantWallets An array of addresses with the list of applicants' wallets.
   * @param _databaseIds An array of addresses with the list of applicants' wallets.
   */
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

  /** @dev Returns the list of database IDs of the added granted applications.
   */
  function getGrantedApplicationIds() external view returns (uint256[] memory) {
    return grantedApplicationIds;
  }

  /** @dev Returns information about the registered granted application.
   * @param _databaseId Database ID of the granted application.
   * @return _certifier Certifier's wallet address.
   * @return _applicant Applicant's wallet address.
   * @return _registrationDate Block Timestamp when the register was added to the smart contract.
   * @return _evidenceHash The evidence hash that validates the personal information of the certifier and the applicant.
   */
  function getGrantedApplication(uint256 _databaseId) external view returns (address _certifier, address _applicant, uint256 _registrationDate, bytes32 _evidenceHash) {
    require(grantedApplicationIsRegistered(_databaseId), "Invalid Application ID");

    _certifier = grantedApplications[_databaseId].certifier;
    _applicant = grantedApplications[_databaseId].applicant;
    _registrationDate = grantedApplications[_databaseId].registrationDate;
    _evidenceHash = grantedApplications[_databaseId].evidenceHash;
  }

  /** @dev Returns true if the granted application database ID is registered. Otherwise, returns false.
   * @param _databaseId Database ID of the granted application.
   */
  function grantedApplicationIsRegistered(uint256 _databaseId) public view returns (bool) {
    return (grantedApplications[_databaseId].evidenceHash > 0);
  }
  
}