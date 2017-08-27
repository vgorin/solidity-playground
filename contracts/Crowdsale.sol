pragma solidity ^0.4.11;

import './ERC20.sol';
import './Transferable.sol';

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
	Transferable public beneficiary;

	// contract creator, owner of the contract
	// creator is also supplier of tokens
	address creator;

	// The token being sold
	ERC20 public token;

	// how many token units a buyer gets per wei
	uint public rate;

	// crowdsale start block number
	uint public offset;

	// crowdsale length in blocks
	uint public length;

	// minimum amount of value to transfer to beneficiary in automatic mode
	uint quantum;

	// crowdsale minimum goal
	uint public softCap;

	// crowdsale maximum goal
	uint public hardCap;

	// how much value collected (funds raised)
	uint public collected;

	// how much value refunded (if crowdsale failed)
	uint public refunded;

	// how much tokens issued to investors
	//uint public tokensIssued;

	// how much tokens redeemed and refunded (if crowdsale failed)
	//uint public tokensRedeemed;

	// how many successful transactions (with tokens being send back) do we have
	//uint public transactions;

	// how many refund transactions (in exchange for tokens) made (if crowdsale failed)
	//uint public refunds;

	// events to log
	event InvestmentAccepted(address indexed holder, uint tokens, uint value);
	event RefundIssued(address indexed holder, uint tokens, uint value);

	function Crowdsale(
		uint _offset,
		uint _length,
		uint _softCap,
		uint _hardCap,
		uint _quantum,
		uint _rate,
		Transferable _beneficiary,
		address _token
	) {
		// validate crowdsale settings (inputs)
		// require(_offset > 0); // TODO: check if offset is not in the past?
		require(_length > 0);
		// softCap can be anything, zero means crowdsale doesn't fail
		// TODO: support zero hardCap (unlimited crowdsale)
		require(_hardCap > _softCap); // hardCap must be greater then softCap
		// quantum can be anything, zero means no accumulation
		require(_rate > 0);
		require(_beneficiary != address(0));
		require(_token != address(0));

		// setup crowdsale settings
		offset = _offset;
		length = _length;
		softCap = _softCap;
		hardCap = _hardCap;
		quantum = _quantum;
		rate = _rate;
		beneficiary = _beneficiary;
		creator = msg.sender;

		// link tokens, tokens are not owned by a crowdsale
		// should be approved for transfer by crowdsale after the deployment
		token = ERC20(_token);
	}

	// accepts crowdsale investment, requires
	// crowdsale to be running and not reached its goal
	function invest() payable {
		// perform validations
		require(block.number >= offset); // crowdsale started
		require(block.number < offset + length); // crowdsale has not ended
		require(collected + rate <= hardCap); // its still possible to buy at least 1 token
		require(msg.value >= rate); // value sent is enough to buy at least one token

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

		// transfer the change to investor
		investor.transfer(msg.value - value);

		// accumulate the value or transfer it to beneficiary
		if(value + collected >= softCap && this.balance >= quantum) {
			// transfer all the value to beneficiary
			beneficiary.transfer(this.balance);
		}

		// update crowdsale status
		collected += value;
		//tokensIssued += tokens;
		//transactions++;

		// log an event
		InvestmentAccepted(investor, tokens, value);
	}

	// refunds an investor of failed crowdsale,
	// requires investor to allow token transfer back
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
		require(refundValue <= this.balance);

		// transfer the tokens back
		token.transferFrom(investor, this, tokens);

		// make a refund
		investor.transfer(refundValue + msg.value);

		// update crowdsale status
		refunded += refundValue;
		//tokensRedeemed += tokens;
		//refunds++;

		// log an event
		RefundIssued(investor, tokens, refundValue);
	}

	// sends all the value to the beneficiary
	function withdraw() payable {
		// perform validations
		require(creator == msg.sender); // only creator can initiate this call
		require(collected >= softCap); // crowdsale must be successful
		require(this.balance > 0); // there should be something to transfer

		// how much to withdraw (entire balance obviously)
		uint value = this.balance;

		// perform the transfer
		beneficiary.transfer(value);
	}

	// performs an investment, refund or withdrawal,
	// depending on the crowdsale status
	function() payable {
		if(block.number < offset + length) {
			// crowdsale is running, invest
			invest();
		}
		else if(collected < softCap) {
			// crowdsale failed, try to refund
			refund();
		}
		else {
			// crowdsale is successful, investments are not accepted anymore
			// but maybe poor beneficiary is begging for change...
			withdraw();
		}
	}

}
