pragma solidity ^0.4.11;

import './ERC20Token.sol';

// FixedERC20 - fixed supply token is a basic,
// full (not abstract) implementation of ERC20 interface
contract FixedERC20 is ERC20Token {
	uint __totalSupply;

	function FixedERC20(uint _totalSupply) {
		// set the __totalSupply
		__totalSupply = _totalSupply;

		// init token balance of the owner, all tokens go to him
		balances[msg.sender] = _totalSupply;
	}

	// total supply is constant
	function totalSupply() constant returns (uint totalSupply) {
		return __totalSupply;
	}
}
