pragma solidity 0.4.18;

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
	function SharedAccumulator(address[] beneficiaries, uint[] shares, uint[] thresholds) public {
		// input validation
		t = Transfers.create(beneficiaries, shares, thresholds);
	}

	// allocates current balance to beneficiaries
	function update() public {
		t.update(this.balance);
	}

	// performs immediate transfer (to the caller)
	function withdraw() public {
		t.withdraw(msg.sender);
	}

	// performs immediate transfer (for everyone)
	function withdrawAll() public {
		t.withdrawAll();
	}

	// payable fallback, can be executed on stipend
	function() public payable {
		// accumulate, must be executed on stipend - 2300 gas
	}

}
