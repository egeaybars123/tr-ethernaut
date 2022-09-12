// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Token {

  mapping(address => uint) balances;
  uint public totalSupply;

  constructor(uint _initialSupply) public {
    balances[msg.sender] = totalSupply = _initialSupply;
  }

  function transfer(address _to, uint _value) public returns (bool) {
    require(balances[msg.sender]  - _value >= 0); //20-21 = max sayı
    balances[msg.sender] -= _value; //2^256 - 1, minimum sayı = 0
    balances[_to] += _value;
    return true;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}

//Kilometre sayacı (4 haneli):
//9999 -> 0000
//Integer underflow-overflow.