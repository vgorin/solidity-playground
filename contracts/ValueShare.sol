pragma solidity ^0.4.11;

// shares incoming value between the beneficiaries according to their shares
contract ValueShare {
	address[] beneficiaries;
	uint[] shares;
	uint[] thresholds;
	uint quantum;

	// current threshold index
	uint private idx;

	// total amount of transferred value, used with thresholds
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
		uint value = this.balance; // total value to share
		uint n = beneficiaries.length; // number of beneficiaries
		uint[] memory values = new uint[](n); // value to send to each of beneficiaries

		for(
			uint current = transferred; // current active threshold
			thresholds[idx] != 0 && transferred + value > thresholds[idx];
			current = thresholds[idx++] // update both current threshold and idx
		) {
			// calculate each beneficiary value share in between thresholds
			__split(n, values, thresholds[idx] - current);
		}

		// all the thresholds are crossed, calculate the rest
		__split(n, values, value - current + transferred);

		// send the values
		for(uint i = 0; i < n; i++) {
			beneficiaries[i].transfer(values[i]);
		}

		// updates status
		transferred += value;
	}

	// n - number of beneficiaries, values array length
	// values - array to accumulate each beneficiary value share during current transfer
	// value - total value during current round of transfer
	function __split(uint n, uint[] memory values, uint value) internal {
		// temporary variable for simple loops
		uint i;

		// temp variables to fix rounding off discrepancy
		uint v0 = 0;
		uint vi;

		// total share
		uint share = 0;

		// calculate total share for current round
		for(i = 0; i < n; i++) {
			share += shares[idx * n + i];
		}

		// calculate each beneficiary value share
		for(i = 0; i < n; i++) {
			vi = value / share * shares[idx * n + i]; // i-th for current round
			values[i] += vi; // increment beneficiary's share
			v0 += vi; // total for current round
		}

		// fix rounding off discrepancy
		values[0] += value - v0;
	}

}
