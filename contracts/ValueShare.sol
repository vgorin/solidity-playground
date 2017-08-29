pragma solidity ^0.4.11;

// shares incoming value between the beneficiaries according to their shares
contract ValueShare {
	address[] beneficiaries;
	uint[] shares;
	uint[] thresholds;
	uint quantum;

	uint private idx;

	uint public transferred;

	// beneficiaries - an array of beneficiary addresses
	// shares - their shares, shares[i] is beneficiaries[i] share
	// thresholds - allows changing of the share proportion depending on amount of value processed
	function ValueShare(address[] _beneficiaries, uint[] _shares, uint[] _thresholds, uint _quantum) {
		// input validation
		require(_beneficiaries.length > 0);
		require(_shares.length > 0);
		require(_shares.length == _thresholds.length * _beneficiaries.length);
		require(_thresholds[_thresholds.length - 1] == 0);

		for(uint i = 0; i < _beneficiaries.length; i++) {
			require(_beneficiaries[i] != address(0));
		}

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

		// define auxiliary variables
		uint i; // temporary variable for simple loops
		uint share; // total share
		uint value = this.balance; // total value to share
		uint n = beneficiaries.length; // number of beneficiaries
		uint[] memory values = new uint[](n); // value to send to each of beneficiaries

		// calculate total share
		for(i = 0; i < n; i++) {
			share += shares[idx * n + i];
		}

		// calculate each beneficiary value share
		for(i = 0; i < n; i++) {
			values[i] = value / share * shares[i];
		}

		// send the values
		for(i = 0; i < n; i++) {
			beneficiaries[i].transfer(values[i]);
		}

		// updates status
		transferred += value;
	}

}
