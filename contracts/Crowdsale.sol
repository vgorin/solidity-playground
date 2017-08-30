pragma solidity ^0.4.11;

import './token/ERC20.sol';
import './token/ConfigurableERC20.sol';

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to beneficiary
 * as they arrive.
 * A crowdsale is defined by:
 *   offset (required) - crowdsale start, the first operational block number
 *   length (required) - number of blocks crowdsale is operational, the last operational block is offset + length - 1
 *   rate (required) - token price in wei
 *   soft cap (optional) - minimum amount of funds required for crowdsale success, can be zero (if not used)
 *   hard cap (optional) - maximum amount of funds crowdsale can accept, can be zero (unlimited)
 *   quantum (optional) - enables value accumulation effect to reduce value transfer costs, usually is not used (set to zero)
 *     if non-zero value passed specifies minimum amount of wei to transfer to beneficiary
 *
 * Open crowdsale (aka attached crowdsale) doesn't own tokens and doesn't perform any token emission.
 * It expects enough tokens to be available on its address:
 * these tokens are used for issuing them to investors.
 * Token redemption is done in opposite way: tokens accumulate back on contract's address
 * Beneficiary is specified by its address.
 * Use this implementation if you need to make several crowdsales with the same token being sold.
 *
 * Closed crowdsale owns all the tokens, it guarantees no token emission will occur outside the crowdsale.
 * The tokens created by a crowdsale are used for issuing them to investors.
 * Token redemption is done in opposite way: tokens accumulate back on crowdsale's address
 * Beneficiary is specified by its address.
 *
 * Use this implementation if you won't have several crowdsales with the same token being sold.
 *
 */
contract Crowdsale {
	// contract creator, owner of the contract
	// creator is also supplier of tokens
	address creator;

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

	// The token being sold
	ERC20 public token;

	// address where funds are collected
	address public beneficiary;

	// events to log
	event InvestmentAccepted(address indexed holder, uint tokens, uint value);
	event RefundIssued(address indexed holder, uint tokens, uint value);

	// a crowdsale is defined by a set of parameters passed here
	// make sure _offset + _length block is in the future in order for crowdsale to be operational
	// _rate must be positive, this is a price of one token in wei
	// _hardCap must be greater then _softCap or zero, zero _hardCap means unlimited crowdsale
	// _quantum may be zero, in this case there will be no value accumulation on the contract
	function Crowdsale(
		uint _offset,
		uint _length,
		uint _rate,
		uint _softCap,
		uint _hardCap,
		uint _quantum,
		address _beneficiary,
		address _token, // zero for closed crowdsale
		string _symbol,
		string _name,
		uint _decimals
	) {
		// validate crowdsale settings (inputs)
		// require(_offset > 0); // we don't really care
		require(_length > 0);
		// softCap can be anything, zero means crowdsale doesn't fail
		require(_hardCap > _softCap || _hardCap == 0); // hardCap must be greater then softCap
		// quantum can be anything, zero means no accumulation
		require(_rate > 0);
		require(_beneficiary != address(0));
		require(_token != address(0) || (bytes(_symbol).length > 0 && bytes(_name).length > 0));

		// setup crowdsale settings
		offset = _offset;
		length = _length;
		softCap = _softCap;
		hardCap = _hardCap;
		quantum = _quantum;
		rate = _rate;
		creator = msg.sender;

		// define beneficiary
		beneficiary = _beneficiary;

		// allocate tokens
		__allocateTokens(_token, _symbol, _name, _decimals);
	}

	// accepts crowdsale investment, requires
	// crowdsale to be running and not reached its goal
	function invest() payable {
		// perform validations
		require(block.number >= offset); // crowdsale started
		require(block.number < offset + length); // crowdsale has not ended
		require(collected + rate <= hardCap || hardCap == 0); // its still possible to buy at least 1 token
		require(msg.value >= rate); // value sent is enough to buy at least one token

		// call 'sender' nicely - investor
		address investor = msg.sender;

		// how much tokens we must send to investor
		uint tokens = msg.value / rate;

		// how much value we must send to beneficiary
		uint value = tokens * rate;

		// ensure we are not crossing the hardCap
		if(value + collected > hardCap || hardCap == 0) {
			value = hardCap - collected;
			tokens = value / rate;
			value = tokens * rate;
		}

		// transfer tokens to investor
		__issueTokens(investor, tokens);

		// transfer the change to investor
		investor.transfer(msg.value - value);

		// accumulate the value or transfer it to beneficiary
		if(value + collected >= softCap && this.balance >= quantum) {
			// transfer all the value to beneficiary
			__beneficiaryTransfer(this.balance);
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
		uint tokens = __redeemAmount(investor);

		// calculate refund amount
		uint refundValue = tokens * rate;

		// additional validations
		require(tokens > 0);
		require(refundValue <= this.balance);

		// transfer the tokens back
		__redeemTokens(investor, tokens);

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
		__beneficiaryTransfer(value);
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



	// ----------------------- internal section -----------------------

	// allocates token source, supports both open and closed crowdsales
	function __allocateTokens(address _token, string _symbol, string _name, uint _decimals) internal {
		if(_token != address(0)) {
			// link tokens, tokens are not owned by a crowdsale
			// should be transferred to crowdsale after the deployment
			token = ERC20(_token);
		}
		else {
			// additional requirement: closed crowdsale cannot be unlimited
			require(hardCap > rate);

			// calculate total token supply
			uint _totalSupply = hardCap / rate;

			// create tokens, tokens are owned by a crowdsale
			token = new ConfigurableERC20(_symbol, _name, _decimals, _totalSupply);
		}
	}

	// transfers tokens to investor, validations are not required
	function __issueTokens(address investor, uint tokens) internal {
		token.transfer(investor, tokens);
	}

	// calculates amount of tokens available to redeem from investor, validations are not required
	function __redeemAmount(address investor) internal returns (uint amount) {
		return token.allowance(investor, this);
	}

	// transfers tokens from investor, validations are not required
	function __redeemTokens(address investor, uint tokens) internal {
		token.transferFrom(investor, this, tokens);
	}

	// transfers a value to beneficiary, validations are not required
	function __beneficiaryTransfer(uint value) internal {
		beneficiary.transfer(value);
	}

	// !---------------------- internal section ----------------------!

}
