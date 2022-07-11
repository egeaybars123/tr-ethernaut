//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Function {
    function encodeFunction() pure public returns (bytes4){
        bytes4 sig = bytes4(keccak256("pwn()"));
        return sig;
    }
}