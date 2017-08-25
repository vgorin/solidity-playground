pragma solidity ^0.4.11;

import './Transferable.sol';

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale {
	// The token being sold
	Transferable public token;

	// start block number and number of blocks where investments are allowed (both inclusive)
	uint public offset;
	uint public length;

	// crowdsale goals (min, max)
	uint public softCap;
	uint public hardCap;

	// minimum amount of value to transfer to beneficiary in automatic mode
	uint public quantum;

	// current contract balance
	uint public balance;

	// how much funds raised
	uint public collected;

	// how much tokens sold
	uint public tokensSold;

	// address where funds are collected
	address public beneficiary;

	// how many token units a buyer gets per wei
	uint public rate;

	// how many successful transactions (with tokens being send back) do we have
	uint public transactions;

	function Crowdsale(
		uint _offset,
		uint _length,
		uint _softCap,
		uint _hardCap,
		uint _quantum,
		uint _rate,
		address _token,
		address _beneficiary
	) {
		// validate crowdsale settings (inputs)
		require(_offset > 0);
		require(_length > 0);
		require(_softCap > 0);
		require(_hardCap > _softCap);
		require(_quantum > 0);
		require(_rate > 0);
		require(_token != address(0));
		require(_beneficiary != address(0));

		// setup crowdsale settings
		offset = _offset;
		length = _length;
		softCap = _softCap;
		hardCap = _hardCap;
		quantum = _quantum;
		rate = _rate;
		beneficiary = _beneficiary;

		// link tokens, owned by a crowdsale
		token = Transferable(_token);
	}

	function() payable {
		// perform validations
		require(block.number >= offset);
		require(block.number <= offset + length);
		require(msg.value >= rate); // this also ensures buying at least one token

		// call 'sender' nicely - investor
		address investor = msg.sender;

		// how much tokens we must send to investor
		uint tokens = msg.value / rate;

		// how much value we must send to beneficiary
		uint value = tokens * rate;

		// ensure we are not crossing the hardCap
		require(value + collected <= hardCap);

		// transfer tokens to investor
		token.transfer(investor, tokens);

		// accumulate the value or transfer it to beneficiary
		if(value + collected < softCap || value + balance < quantum) {
			// accumulate
			balance += value;
		}
		else {
			// transfer
			beneficiary.transfer(value + balance);
		}

		// transfer the change to investor
		investor.transfer(msg.value - value);

		// update crowdsale status
		collected += value;
		tokensSold += tokens;
		transactions++;

	}

}
