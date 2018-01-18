pragma solidity 0.4.18;

import './ERC20Token.sol';

// FixedERC20 - fixed supply token is a basic,
// full (not abstract) implementation of ERC20 interface
contract FixedERC20 is ERC20Token {
	// fixed token total supply, cannot be changed over time
	uint __totalSupply;

	function FixedERC20(uint _totalSupply) public {
		// total supply must not be zero
		require(_totalSupply > 0);

		// set the __totalSupply
		__totalSupply = _totalSupply;

		// init token balance of the owner, all tokens go to him
		balances[msg.sender] = _totalSupply;
	}

	// total supply is constant
	function totalSupply() public constant returns (uint _totalSupply) {
		return __totalSupply;
	}
}
