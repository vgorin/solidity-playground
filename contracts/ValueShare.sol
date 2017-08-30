pragma solidity ^0.4.11;

import './lib/Transfers.sol';

// shares incoming value between the beneficiaries according to their shares
contract ValueShare {
	// using Transfers library for Transfer struct
	using Transfers for Transfers.Shared;

	// transfer structure
	Transfers.Shared t;

	// quantization
	uint quantum;

	// beneficiaries - an array of beneficiary addresses
	// shares - their shares, shares[i] is beneficiaries[i] share
	// thresholds - allows changing of the share proportion depending on amount of value processed
	function ValueShare(address[] _beneficiaries, uint[] _shares, uint[] _thresholds, uint _quantum) {
		// input validation
		t = Transfers.create(_beneficiaries, _shares, _thresholds);

		// setup quantum
		quantum = _quantum;
	}

	function() payable {
		// quantization
		if(this.balance < quantum) {
			return;
		}

		// perform the transfer
		t.transferValue(this.balance);
	}

}
