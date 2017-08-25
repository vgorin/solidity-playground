pragma solidity ^0.4.11;

import './Transferable.sol';
import './AgraraToken.sol';

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
	uint256 public offset;
	uint256 public length;

	// crowdsale goals (min. max)
	uint256 public goalMin;
	uint256 public goalMax;

	// how much funds raised
	uint256 public fundsRaised;

	// address where funds are collected
	address public wallet;

	// how many token units a buyer gets per wei
	uint256 public rate;

	function Crowdsale(
		uint256 _offset,
		uint256 _length,
		uint256 _goalMin,
		uint256 _goalMax,
		uint256 _rate,
		uint256 _totalSupply,
		address _wallet
	) {
		// validate crowdsale settings (inputs)
		require(_offset > 0);
		require(_length > 0);
		require(_goalMin > 0);
		require(_goalMax > _goalMin);
		require(_rate > 0);
		require(_totalSupply > 0);
		require(_wallet != address(0));

		// setup crowdsale settings
		offset = _offset;
		length = _length;
		goalMin = _goalMin;
		goalMax = _goalMax;
		rate = _rate;
		wallet = _wallet;

		// create tokens, owned by a crowdsale
		token = new AgraraToken(_totalSupply);
	}

	function() payable {
		// perform validations
		require(block.number >= offset);
		require(block.number <= offset + length);
		require(msg.value >= rate);

		// transfer tokens
		token.transfer(msg.sender, msg.value / rate);

		// transfer funds
		wallet.transfer(msg.value);

		// update crowdsale status
		fundsRaised += msg.value;

		// log successful fund receive event
		FundsReceived(msg.sender, msg.value, rate);
	}

	event FundsReceived(address indexed investorAddress, uint256 value, uint256 rate);
}
