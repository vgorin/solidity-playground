pragma solidity ^0.4.11;

import './lib/Transfers.sol';

// shares incoming value between the beneficiaries according to their shares
// on-demand edition of SharedTransfer
contract SharedAccumulator {
	// using Transfers library for Transfer struct
	using Transfers for Transfers.Shared;

	// transfer structure
	Transfers.Shared t;

	// beneficiaries - an array of beneficiary addresses
	// shares - their shares, shares[i] is beneficiaries[i] share
	// thresholds - allows changing of the share proportion depending on amount of value processed
	function SharedAccumulator(address[] beneficiaries, uint[] shares, uint[] thresholds) {
		// input validation
		t = Transfers.create(beneficiaries, shares, thresholds);
	}

	function withdraw() {
		// perform immediate transfer
		t.transferValue(this.balance);
	}

	// payable fallback, can be executed on stipend
	function() payable {
		// accumulate, must be executed on stipend - 2300 gas
	}

}
