pragma solidity 0.4.18;

import './SharedAccumulator.sol';

// shares incoming value between the beneficiaries according to their shares
contract SharedTransfer is SharedAccumulator {

	// inherited constructor
	function SharedTransfer(address[] beneficiaries, uint[] shares, uint[] thresholds) SharedAccumulator(beneficiaries, shares, thresholds) public {}

	// payable fallback, complex
	function() public payable {
		t.append(msg.value);
	}

}
