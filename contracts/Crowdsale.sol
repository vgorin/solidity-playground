pragma solidity ^0.4.11;

import './ERC20.sol';

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to beneficiary
 * as they arrive.
 */
contract Crowdsale {
	// The token being sold
	ERC20 public token;

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

	// how much refunded (if crowdsale failed)
	uint public refunded;

	// how much tokens sold
	uint public tokensSold;

	// how much tokens refunded (if crowdsale failed)
	uint public tokensRefunded;

	// address where funds are collected
	address public beneficiary;

	// how many token units a buyer gets per wei
	uint public rate;

	// how many successful transactions (with tokens being send back) do we have
	uint public transactions;

	// how many refund transactions (in exchange for tokens) made (if crowdsale failed)
	uint public refunds;

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
		token = ERC20(_token);
	}

/*
	function softCapReached() constant external returns (bool) {
		return collected >= softCap;
	}

	function hardCapReached() constant external returns (bool) {
		return collected >= hardCap;
	}

	function hasStarted() constant external returns (bool) {
		return block.number >= offset;
	}

	function hasEnded() constant external returns (bool) {
		return block.number >= offset + length || collected >= hardCap;
	}

	function isRunning() constant external returns (bool) {
		return block.number >= offset && block.number < offset + length && collected < hardCap;
	}

	function isRunningSuccessfully() constant external returns (bool) {
		return block.number >= offset && block.number < offset + length && collected < hardCap && collected >= softCap;
	}

	function progressByValue() constant external returns (uint) {
		return 100 * collected / hardCap; // TODO: allow to change the precision
	}

	function progressInTime() constant external returns (uint) {
		return 100 * (block.number - offset) / length; // TODO: allow to change the precision
	}
*/

	// accepts crowdsale investment, requires
	// crowdsale to be running and not reached its goal
	function invest() payable {
		// perform validations
		require(block.number >= offset); // crowdsale started
		require(block.number < offset + length); // crowdsale has not ended
		require(collected + rate <= hardCap); // its still possible to buy at least 1 token
		require(msg.value >= rate); // this also ensures buying at least one token

		// call 'sender' nicely - investor
		address investor = msg.sender;

		// how much tokens we must send to investor
		uint tokens = msg.value / rate;

		// how much value we must send to beneficiary
		uint value = tokens * rate;

		// ensure we are not crossing the hardCap
		if(value + collected > hardCap) {
			value = hardCap - collected;
			tokens = value / rate;
			value = tokens * rate;
		}

		// transfer tokens to investor
		token.transfer(investor, tokens);

		// accumulate the value or transfer it to beneficiary
		if(value + collected < softCap || value + balance < quantum) {
			// accumulate
			balance += value;
		}
		else {
			// transfer all the value
			beneficiary.transfer(value + balance);
			// set balance to zero
			balance = 0;
		}

		// transfer the change to investor
		investor.transfer(msg.value - value);

		// update crowdsale status
		collected += value;
		tokensSold += tokens;
		transactions++;
	}

	// refunds an investor of crowdsale has failed,
	// requires investor to allow token transfer back to crowdsale
	function refund() payable {
		// perform validations
		require(block.number >= offset + length); // crowdsale ended
		require(collected < softCap); // crowdsale failed

		// call 'sender' nicely - investor
		address investor = msg.sender;

		// find out how much tokens should be refunded
		uint tokens = token.allowance(investor, this);

		// calculate refund amount
		uint refundValue = tokens * rate;

		// additional validations
		require(tokens > 0);
		require(refundValue <= balance);

		// transfer the tokens back
		token.transferFrom(investor, this, tokens);

		// make a refund
		investor.transfer(refundValue + msg.value);

		// update crowdsale status
		balance -= refundValue;
		refunded += refundValue;
		tokensRefunded += tokens;
		refunds++;
	}

	// performs an investment or a refund,
	// depending on the crowdsale status
	function() payable {
		if(block.number < offset + length) {
			// crowdsale is running, invest
			invest();
		}
		else {
			// crowdsale ended, try to refund
			refund();
		}
	}

}
