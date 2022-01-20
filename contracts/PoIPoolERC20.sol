// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

contract PoIPoolERC20 is Initializable {

  using SafeMath for uint256;
  using SafeERC20Upgradeable for IERC20Upgradeable;

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

  /* Handle Ether */

  fallback() external payable {
    emit Received(msg.sender, msg.value);
  }
    
  receive() external payable {
    emit Received(msg.sender, msg.value);
  }

  function getEtherBalance() public view returns (uint256) {
    return address(this).balance;
  }

  function withdrawEther(uint256 _amount) external onlyByGovernor {
    require(_amount <= getEtherBalance(), "Insufficient funds");
    payable(governor).transfer(_amount);
    emit TransferEtherSent(governor, _amount);
  }

  function transferEther(address _to, uint256 _amount) external onlyByGovernor {
    require(_to != address(0x00), "Cannot burn Ether");
    require(_to != address(this), "Cannot send Ether to itself");
    require(_to != governor, "Use withdrawEther instead");
    require(_amount <= getEtherBalance(), "Insufficient funds");
    payable(_to).transfer(_amount);
    emit TransferEtherSent(_to, _amount);
  }
  
  /* Handle other ERC20 tokens */

  function getERC20Balance(IERC20Upgradeable _token) public view returns (uint256) {
    return _token.balanceOf(address(this));
  }

  function withdrawERC20(IERC20Upgradeable _token, uint256 _amount) external onlyByGovernor {
    uint256 balance = _token.balanceOf(address(this));
    require(_amount <= balance, "Insufficient funds");
    _token.safeTransfer(governor, _amount);
    emit TransferERC20Sent(address(_token), governor, _amount);
  }

  function transferERC20(IERC20Upgradeable _token, address _to, uint256 _amount) external onlyByGovernor {
    require(_to != address(0x00), "Cannot burn ERC20 Token");
    require(_to != address(this), "Cannot send ERC20 Token to itself");
    require(_to != governor, "Use withdrawERC20 instead");
    uint256 balance = _token.balanceOf(address(this));
    require(_amount <= balance, "Insufficient funds");
    _token.safeTransfer(_to, _amount);
    emit TransferERC20Sent(address(_token), _to, _amount);
  }

}