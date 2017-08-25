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
	// address where funds are collected
	address public beneficiary;

	// The token being sold
	ERC20 public token;

	// how many token units a buyer gets per wei
	uint public rate;

	// crowdsale start block number
	uint public offset;

	// crowdsale length in blocks
	uint public length;

	// minimum amount of value to transfer to beneficiary in automatic mode
	uint public quantum;

	// crowdsale minimum goal
	uint public softCap;

	// crowdsale maximum goal
	uint public hardCap;

	// current contract balance
	uint public balance;

	// how much value collected (funds raised)
	uint public collected;

	// how much value refunded (if crowdsale failed)
	uint public refunded;

	// how much tokens released to investors
	uint public tokensReleased;

	// how much tokens refunded (if crowdsale failed)
	uint public tokensRefunded;

	// how many successful transactions (with tokens being send back) do we have
	uint public transactions;

	// how many refund transactions (in exchange for tokens) made (if crowdsale failed)
	uint public refunds;

	// events
	event GoalReached(uint amountRaised);
	event SoftCapReached(uint softCap);
	event InvestementAccepted(address indexed holder, uint256 tokenAmount, uint256 etherAmount);
	event RefundIssued(address indexed holder, uint256 amount);

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

		// link tokens, tokens are not owned by a crowdsale
		// should be transferred to crowdsale after deployment
		token = ERC20(_token);
	}

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
			// transfer all the value to beneficiary
			beneficiary.transfer(value + balance);
			// set balance to zero
			balance = 0;
		}

		// transfer the change to investor
		investor.transfer(msg.value - value);

		// update crowdsale status
		collected += value;
		tokensReleased += tokens;
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

	// sends all the value to the beneficiary
	function withdraw() payable {
		// perform validations
		require(beneficiary == msg.sender); // only beneficiary can initiate this call
		require(collected >= softCap); // crowdsale must be successful
		require(balance > 0); // there should be something to transfer

		// perform the transfer
		beneficiary.transfer(msg.value + balance);
	}

	// performs an investment, refund or withdrawal,
	// depending on the crowdsale status
	function() payable {
		if(block.number < offset + length) {
			// crowdsale is running, invest
			invest();
		}
		else if(collected < softCap) {
			// crowdsale ended, try to refund
			refund();
		}
		else {
			// maybe poor beneficiary is begging for change...
			withdraw();
		}
	}

}
