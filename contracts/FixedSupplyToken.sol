pragma solidity ^0.4.11;

import './ERC20Token.sol';

contract FixedSupplyToken is ERC20Token {
	uint256 __totalSupply;

	function FixedSupplyToken(uint256 _totalSupply) {
		__totalSupply = _totalSupply;
	}

	function totalSupply() constant returns (uint256 totalSupply) {
		return __totalSupply;
	}
}
