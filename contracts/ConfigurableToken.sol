pragma solidity ^0.4.11;

import './FixedSupplyToken.sol';

contract ConfigurableToken is FixedSupplyToken {
	string public symbol;
	string public name;
	uint256 public decimals;

	function ConfigurableToken(
		string _symbol,
		string _name,
		uint256 _decimals,
		uint256 _totalSupply
	) FixedSupplyToken(_totalSupply) {
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
