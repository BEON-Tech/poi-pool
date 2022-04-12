// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

interface IUBI {
  function balanceOf(address _human) external view returns (uint256 balance);

  function transfer(address _recipient, uint256 _amount) external returns (bool transferred);

  function withdrawFromStream(uint256 streamId) external;
}

contract PoIPoolUBI is Initializable {
  /* Events */

  event UBIDistributed(uint256 totalHumans, uint256 totalUBI);

  /* Storage */

  address public governor;
  IUBI public ubi;
  uint256 public maxUBIPerRecipient;

  /// @dev Verifies that the sender has ability to modify governed parameters.
  modifier onlyByGovernor() {
    require(governor == msg.sender, 'The caller is not the governor.');
    _;
  }

  /* Initializer */

  function initialize(IUBI _ubi, uint256 _maxUBIPerRecipient) public initializer {
    governor = msg.sender;
    ubi = _ubi;
    maxUBIPerRecipient = _maxUBIPerRecipient;
  }

  function claimUBIFromStreams(uint256[] calldata _streamIds) external onlyByGovernor returns (bool) {
    assert(address(ubi) != address(0x0));
    require(_streamIds.length > 0, 'Empty array of stream ids');
    for (uint256 i = 0; i < _streamIds.length; i++) {
      uint256 currentStream = _streamIds[i];
      ubi.withdrawFromStream(currentStream);
    }
    return true;
  }

  function changeMaxUBIPerRecipient(uint256 _maxUBIPerRecipient) external onlyByGovernor {
    maxUBIPerRecipient = _maxUBIPerRecipient;
  }

  function changeIUBI(IUBI _ubi) external onlyByGovernor {
    ubi = _ubi;
  }

  function distributeUBIToRecipients(address[] calldata _humans, uint256 _totalRecipients) external onlyByGovernor returns (bool) {
    assert(address(ubi) != address(0x00));
    require(_totalRecipients > 0, 'Recipients must be greater than zero');
    require(_humans.length <= _totalRecipients, 'Humans must be greater than recipients');
    uint256 valueToDistribute = ubi.balanceOf(address(this)) / _totalRecipients;
    if (valueToDistribute > maxUBIPerRecipient) {
      valueToDistribute = maxUBIPerRecipient;
    }
    require(valueToDistribute > 0, 'Not enough UBIs to distribute');

    uint256 totalHumans = 0;
    uint256 totalTransferred = 0;
    for (uint256 i = 0; i < _humans.length; i++) {
      address currentHuman = _humans[i];
      if (ubi.transfer(currentHuman, valueToDistribute)) {
        totalHumans++;
        totalTransferred += valueToDistribute;
      }
    }

    emit UBIDistributed(totalHumans, totalTransferred);

    return true;
  }
}
