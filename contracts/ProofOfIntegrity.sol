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

  /* Storage */

  address public governor;
  mapping(address => Certifier) certifiers;
  address[] public certifiersAccounts;

  /// @dev Verifies that the sender has ability to modify governed parameters.
  modifier onlyByGovernor() {
    require(governor == msg.sender, "The caller is not the governor.");
    _;
  }

  /* Initializer */

  function initialize() public initializer {
    governor = msg.sender;
  }

  function addCertifier(string calldata _firstname, string calldata _lastname, string calldata _databaseId, address _wallet) external onlyByGovernor {
    _addCertifier(_firstname, _lastname, _databaseId, _wallet);
    emit CertifiersAdded(1);
  }

  function _addCertifier(string calldata _firstname, string calldata _lastname, string calldata _databaseId, address _wallet) internal onlyByGovernor {
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
    require(certifiers[_wallet].evidenceHash > 0, "Invalid wallet address");
    
    _certifierId = certifiers[_wallet].certifierId;
    _registrationDate = certifiers[_wallet].registrationDate;
    _evidenceHash = certifiers[_wallet].evidenceHash;
  }

  function verifyCertifier(address _wallet, string calldata _firstname, string calldata _lastname, string calldata _databaseId) external view returns (bool) {
    return certifiers[_wallet].evidenceHash == keccak256(abi.encodePacked(_firstname, _lastname, _databaseId));
  }

}