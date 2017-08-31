pragma solidity ^0.4.11;

import './SharedAccumulator.sol';

// shares incoming value between the beneficiaries according to their shares
contract SharedTransfer is SharedAccumulator {

	// inherited constructor
	function SharedTransfer(address[] beneficiaries, uint[] shares, uint[] thresholds) SharedAccumulator(beneficiaries, shares, thresholds){}

	// payable fallback, complex
	function() payable {
		// perform withdrawal
		withdraw();
	}

}
