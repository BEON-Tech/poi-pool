// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ProofOfIntegrity is Initializable {

  /* Events */

  event CertifiersAdded(uint256 totalAdded);
  event ApplicantsAdded(uint256 totalAdded);
  event ApplicationsAdded(uint256 totalAdded);

  /* Structs */

  struct Certifier {
    string certifierId;
    uint256 registrationDate;
    bytes32 evidenceHash;
  }

  struct Applicant {
    string applicantId;
    uint256 registrationDate;
    bytes32 evidenceHash;
  }

  /* Storage */

  address public governor;
  mapping(address => Certifier) certifiers;
  mapping(address => Applicant) approvedApplicants;
  address[] public certifiersAccounts;
  address[] public approvedApplicantsAccounts;

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

  function addCertifier(string calldata _firstname, string calldata _lastname, string calldata _databaseId, address _wallet) external onlyByGovernor {
    _addCertifier(_firstname, _lastname, _databaseId, _wallet);
    emit CertifiersAdded(1);
  }

  /**
   * @param _firstnames An array of strings with the list of certifiers' first names.
   * @param _lastnames An array of strings with the list of certifiers' last names.
   * @param _databaseIds An array of strings with the list of certifiers' database IDs.
   * @param _wallets An array of addresses with the list of certifiers' wallets.
   */
  function addCertifiers(string[] calldata _firstnames, string[] calldata _lastnames, string[] calldata _databaseIds, address[] calldata _wallets) external onlyByGovernor {
    require(haveSameLength(_firstnames, _lastnames, _databaseIds, _wallets), "Invalid arrays length");

    for(uint i = 0; i < _firstnames.length; i++) {
      _addCertifier(_firstnames[i], _lastnames[i], _databaseIds[i], _wallets[i]);
    }
    emit CertifiersAdded(_firstnames.length);
  }

  function _addCertifier(string calldata _firstname, string calldata _lastname, string calldata _databaseId, address _wallet) internal onlyByGovernor {
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

  function getCertifier(address _wallet) external view returns (string memory _certifierId, uint256 _registrationDate, bytes32 _evidenceHash) {
    require(certifierIsRegistered(_wallet), "Invalid wallet address");

    _certifierId = certifiers[_wallet].certifierId;
    _registrationDate = certifiers[_wallet].registrationDate;
    _evidenceHash = certifiers[_wallet].evidenceHash;
  }

  function verifyCertifier(address _wallet, string calldata _firstname, string calldata _lastname, string calldata _databaseId) external view returns (bool) {
    require(certifierIsRegistered(_wallet), "Invalid wallet address");

    return certifiers[_wallet].evidenceHash == keccak256(abi.encodePacked(_firstname, _lastname, _databaseId));
  }

  function certifierIsRegistered(address _wallet) public view returns (bool) {
    return (certifiers[_wallet].evidenceHash > 0);
  }

  /** Applicants **/

  function addApprovedApplicant(string calldata _firstname, string calldata _lastname, string calldata _databaseId, address _wallet) external onlyByGovernor {
    _addApprovedApplicant(_firstname, _lastname, _databaseId, _wallet);
    emit ApplicantsAdded(1);
  }

  function addApprovedApplicants() external onlyByGovernor {
    // TODO
  }

  function _addApprovedApplicant(string calldata _firstname, string calldata _lastname, string calldata _databaseId, address _wallet) internal onlyByGovernor {
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

  function getApprovedApplicant(address _wallet) external view returns (string memory _applicantId, uint256 _registrationDate, bytes32 _evidenceHash) {
    require(approvedApplicantIsRegistered(_wallet), "Invalid wallet address");

    _applicantId = approvedApplicants[_wallet].applicantId;
    _registrationDate = approvedApplicants[_wallet].registrationDate;
    _evidenceHash = approvedApplicants[_wallet].evidenceHash;
  }

  function verifyApprovedApplicant(address _wallet, string calldata _firstname, string calldata _lastname, string calldata _databaseId) external view returns (bool) {
    require(approvedApplicantIsRegistered(_wallet), "Invalid wallet address");

    return approvedApplicants[_wallet].evidenceHash == keccak256(abi.encodePacked(_firstname, _lastname, _databaseId));
  }

  function approvedApplicantIsRegistered(address _wallet) public view returns (bool) {
    return (approvedApplicants[_wallet].evidenceHash > 0);
  }

  /** Helpers **/

  function haveSameLength(string[] calldata _first, string[] calldata _second, string[] calldata _third, address[] calldata _fourth) internal pure returns (bool) {
    return (_first.length == _second.length && _third.length == _fourth.length && _first.length == _third.length);
  }

}