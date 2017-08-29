pragma solidity ^0.4.11;

// Contains value transfer related utility functions
library Transfers {
	// used to validate config parameters used in sharedTransfer
	function validateSharedTransferConfig(
		address[] beneficiaries,
		uint[] shares,
		uint[] thresholds
	) {
		// basic validation
		require(beneficiaries.length > 0);
		require(shares.length > 0);
		require(shares.length == thresholds.length * beneficiaries.length);

		// iterate the loops
		uint i;

		// in-depth validation of beneficiaries
		for(i = 0; i < beneficiaries.length; i++) {
			require(beneficiaries[i] != address(0));
		}

		// in-depth validation of thresholds
		uint t = 0;
		for(i = 0; i < thresholds.length - 1; i++) {
			require(t < thresholds[i]);
			t = thresholds[i];
		}
		require(thresholds[thresholds.length - 1] == 0);

	}

	// transfers shares to beneficiaries according to parameters specified
	function sharedTransfer(
		address[] beneficiaries,
		uint[] shares,
		uint[] thresholds,
		uint transferred,
		uint value
	) internal returns (uint payed) {
		// define auxiliary variables
		uint n = beneficiaries.length; // number of beneficiaries
		uint[] memory values = new uint[](n); // value to send to each of beneficiaries

		// find current threshold index
		uint i = 0;
		while(i < thresholds.length && thresholds[i] < transferred){
			i++;
		}

		// process thresholds
		for(
			uint current = transferred; // current active threshold
			thresholds[i] != 0 && transferred + value > thresholds[i];
			current = thresholds[i++] // update both current threshold and idx
		) {
			// calculate each beneficiary value share in between thresholds
			__split(values, shares, i, thresholds[i] - current);
		}

		// all the thresholds are crossed, calculate the rest
		__split(values, shares, i, value - current + transferred);

		// send the values
		for(i = 0; i < n; i++) {
			beneficiaries[i].transfer(values[i]);
		}

		return value;
	}

	// n - number of beneficiaries, values array length
	// values - array to accumulate each beneficiary value share during current transfer
	// value - total value during current round of transfer
	function __split(
		uint[] memory values,
		uint[] shares,
		uint idx,
		uint value
	) internal {
		// number of beneficiaries
		uint n = values.length;

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
