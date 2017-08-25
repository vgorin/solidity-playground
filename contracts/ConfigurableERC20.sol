pragma solidity ^0.4.11;

import './FixedERC20.sol';

// ConfigurableERC20 is a basic token implementation,
// allows defining token symbol, name, decimals -
// this is enough to display in Ethereum Wallet (like Metamask) nicely
contract ConfigurableERC20 is FixedERC20 {
	string public symbol;
	string public name;
	uint public decimals;

	function ConfigurableERC20(
		string _symbol,
		string _name,
		uint _decimals,
		uint _totalSupply
	) FixedERC20(_totalSupply) {
		// perform validations
		assert(decimals <= 18);  // wei

		// assign constants
		symbol = _symbol;
		name = _name;
		decimals = _decimals;


		// init token balance of the owner, all tokens go to him
		balances[msg.sender] = _totalSupply;
	}

}