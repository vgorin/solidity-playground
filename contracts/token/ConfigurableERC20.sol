pragma solidity 0.4.15;

import './ExtendedERC20.sol';
import './FixedERC20.sol';

// ConfigurableERC20 is a basic token implementation,
// allows defining token symbol, name, decimals -
// this is enough to display in Ethereum Wallet (like Metamask) nicely
contract ConfigurableERC20 is ExtendedERC20, FixedERC20 {
	function ConfigurableERC20(
		string _symbol,
		string _name,
		uint8 _decimals,
		uint _totalSupply
	) FixedERC20(_totalSupply) {
		// perform validations
		require(decimals <= 18);  // wei

		// assign constants
		symbol = _symbol;
		name = _name;
		decimals = _decimals;
	}

}
