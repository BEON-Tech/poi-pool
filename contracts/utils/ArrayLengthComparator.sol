// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract ArrayLengthComparator {

  uint256[] private lengths;
  uint256 private sumLength;

  constructor() {
      sumLength = 0;
  }

  function add(string[] calldata _array) public returns (ArrayLengthComparator) {
    _add(_array.length);
    return this;
  }

  function add(address[] calldata _array) public returns (ArrayLengthComparator) {
    _add(_array.length);
    return this;
  }

  function add(uint256[] calldata _array) public returns (ArrayLengthComparator) {
    _add(_array.length);
    return this;
  }

  function _add(uint256 _length) internal {
    lengths.push(_length);
    sumLength += _length;
  }

  function areEqual() public returns (bool) {
    if(lengths.length == 0) {
        return true;
    }

    bool result = lengths[0] * lengths.length == sumLength;

    delete lengths;
    return result;
  }

}