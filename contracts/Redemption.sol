pragma solidity ^0.4.11;

import './token/ERC20.sol';

contract Redemption {
	// contract creator, owner of the contract
	// creator is also supplier of ether to redeem tokens
	address creator;

	// how much wei a seller gets per token
	uint rate;

	// The token being bought
	ERC20 token;

	// _rate must be positive, this is a price of one token in wei
	// _token specifies an address of the ERC20 token to redeem, shouldn't be 0x0
	function Redemption(uint _rate, address _token) {
		require(_rate > 0);
		require(_token != address(0));

		rate = _rate;
		creator = msg.sender;

		__linkToken(_token);
	}

	// transfers tokens back from investor,
	// sends value back to him according to rate
	function redeem() payable {
		// call 'sender' nicely - investor
		address investor = msg.sender;

		// shorten msg.* used
		uint value = msg.value;
		uint balance = this.balance - value;

		// find out how much tokens should be refunded
		uint tokens = __redeemAmount(investor);

		// there should be at least one token allowed for transfer
		require(tokens > 0);

		// calculate refund amount
		uint redeemValue = tokens * rate;

		// if we don't have enough balance, redeem only what we can
		if(redeemValue > balance) {
			// how much tokens to redeem
			tokens = balance / rate;
			// how much value to send for these tokens
			redeemValue = tokens * rate;
		}

		// transfer the tokens back
		__redeemTokens(investor, tokens);

		// make a refund
		investor.transfer(redeemValue + value);

	}

	// allows creator of the redemption to top up the contract
	function topUp() payable {
		// shorten msg.* used
		address sender = msg.sender;
		uint value = msg.value;

		// top up amount should be enough to redeem at leas one token
		require(value >= rate);

		// how much tokens could be redeemed with the value
		uint tokens = value / rate;

		// how much value to collect
		uint redeemValue = tokens * rate;

		// send the change back to sender
		sender.transfer(value - redeemValue);
	}

	// either redeems a value to investor
	// or accepts a top up from creator
	function() payable {
		if(creator == msg.sender) {
			// creator wants to top up the contract
			topUp();
		}
		else {
			// investor wants his value!!!
			redeem();
		}
	}


	// ----------------------- internal section -----------------------

	// links token contract
	function __linkToken(address _token) internal {
		token = ERC20(_token);
	}

	// calculates amount of tokens available to redeem from investor, validations are not required
	function __redeemAmount(address investor) internal returns (uint amount) {
		return token.allowance(investor, this);
	}

	// transfers tokens from investor, validations are not required
	function __redeemTokens(address investor, uint tokens) internal {
		token.transferFrom(investor, this, tokens);
	}

	// !---------------------- internal section ----------------------!

}
