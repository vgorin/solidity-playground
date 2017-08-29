pragma solidity ^0.4.11;

import './Transfers.sol';

// shares incoming value between the beneficiaries according to their shares
contract ValueShare {
	address[] beneficiaries;
	uint[] shares;
	uint[] thresholds;
	uint quantum;

	// total amount of transferred value, used with thresholds
	uint public transferred;

	// beneficiaries - an array of beneficiary addresses
	// shares - their shares, shares[i] is beneficiaries[i] share
	// thresholds - allows changing of the share proportion depending on amount of value processed
	function ValueShare(address[] _beneficiaries, uint[] _shares, uint[] _thresholds, uint _quantum) {
		// input validation
		Transfers.validateSharedTransferConfig(_beneficiaries, _shares, _thresholds);

		// setup
		beneficiaries = _beneficiaries;
		shares = _shares;
		thresholds = _thresholds;
		quantum = _quantum;
	}

	function() payable {
		// quantization
		if(this.balance < quantum) {
			return;
		}

		// updates transferred status
		transferred += Transfers.sharedTransfer(beneficiaries, shares, thresholds, transferred, this.balance);
	}

}
