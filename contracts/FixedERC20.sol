pragma solidity ^0.4.11;

import './ERC20Token.sol';

// FixedERC20 - fixed supply token is a basic,
// full (not abstract) implementation of ERC20 interface
contract FixedERC20 is ERC20Token {
	uint __totalSupply;

	function FixedERC20(uint _totalSupply) {
		__totalSupply = _totalSupply;
	}

	function totalSupply() constant returns (uint totalSupply) {
		return __totalSupply;
	}
}
