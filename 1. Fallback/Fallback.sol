// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';

contract Fallback {

  using SafeMath for uint256;
  mapping(address => uint) public contributions;
  address public owner;

  constructor() {
    owner = payable(msg.sender);
    contributions[msg.sender] = 1000 * (1 ether);
  }

  modifier onlyOwner {
        require(
            msg.sender == owner,
            "caller is not the owner"
        );
        _;
    }

  function contribute() external payable {
    require(msg.value < 0.001 ether);
    contributions[msg.sender] += msg.value;
    if (contributions[msg.sender] > contributions[owner]) {
      owner = msg.sender;
    }
  }

  function getContribution() public view returns (uint) {
    return contributions[msg.sender];
  }

  function withdraw() public onlyOwner {
    payable(owner).transfer(address(this).balance);
  }

  receive() external payable { //1 wei
    //msg.data yok.
    //msg.value var.
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = msg.sender;
  }

  fallback() external {
    //msg.data var.
    //msg.value olmak zorunda değil.
  }
}