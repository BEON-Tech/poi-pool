// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

contract PoIPoolERC20 is Initializable {

  using SafeMath for uint256;

  /* Events */

  event Received(address sender, uint256 amount);
  event TransferEtherSent(address receiver, uint256 amount);
  event TransferERC20Sent(address token, address receiver, uint256 amount);

  /* Storage */
  address public governor;

  /// @dev Verifies that the sender has ability to modify governed parameters.
  modifier onlyByGovernor() {
    require(governor == msg.sender, "The caller is not the governor.");
    _;
  }

  /* Initializer */

  function initialize() public initializer {
    governor = msg.sender;
  }

  /* To handle Ether */

  fallback() external payable {
    emit Received(msg.sender, msg.value);
  }
    
  receive() external payable {
    emit Received(msg.sender, msg.value);
  }

  function getEtherBalance() public view returns (uint256) {
    return address(this).balance;
  }

  function withdrawEther(uint256 amount) external onlyByGovernor {
    require(amount < getEtherBalance(), "Insufficient funds");
    payable(governor).transfer(amount);
    emit TransferEtherSent(governor, amount);
  }
  
  /* To handle other ERC20 tokens */

  // TODO

}