pragma solidity ^0.4.15;

import '../token/ERC20.sol';

// Contains value transfer related utility functions
library Transfers {
	// base structure for storing config and current state
	struct Shared {
		address[] beneficiaries; // config
		uint[] shares; // config
		uint[] thresholds; // config
		uint transferred; // current status
		uint idx; // current threshold index
	}

	// used to validate config parameters used in sharedTransfer
	function create(address[] beneficiaries, uint[] shares, uint[] thresholds) internal returns (Shared) {
		// basic validation
		require(beneficiaries.length > 0);
		require(beneficiaries.length < 32); // protect from 'DoS with Block Gas Limit'
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

		// create shared transfer struct
		return Shared(beneficiaries, shares, thresholds, 0, 0);
	}

	// transfers shares to beneficiaries according to parameters specified
	function transferValue(Shared storage t, uint value) internal {
		// quantization
		if(value == 0) {
			return;
		}

		// define auxiliary variables
		uint n = t.beneficiaries.length; // number of beneficiaries
		uint[] memory values = new uint[](n); // value to send to each of beneficiaries

		// process thresholds
		for(
			uint current = t.transferred; // current active threshold
			t.thresholds[t.idx] != 0 && t.transferred + value > t.thresholds[i];
			current = t.thresholds[t.idx++] // update both current threshold and idx
		) {
			// calculate each beneficiary value share in between thresholds
			__split(values, t.shares, t.idx, t.thresholds[t.idx] - current);
		}

		// all the thresholds are crossed, calculate the rest
		__split(values, t.shares, t.idx, value - current + t.transferred);

		// update status
		t.transferred += value;

		// send the values
		for(uint i = 0; i < n; i++) {
			t.beneficiaries[i].transfer(values[i]);
		}
	}

/*
	// performs actual value transfer, should be called after approveValue
	function transferValue(Shared storage t, address recipient) internal {
		// recipient's balance must be positive
		require(t.balances[recipient] > 0);

		// update balance first
		t.balances[recipient] = 0;

		// transfer the value after
		recipient.transfer(t.balances[recipient]);
	}

	// performs actual value transfer to all beneficiaries, should be called after approveValue
	function transferAll(Shared storage t) internal {
		for(uint i = 0; i < t.beneficiaries.length; i++) {
			transferValue(t, t.beneficiaries[i]);
		}
	}
*/

	// n - number of beneficiaries, values array length
	// values - array to accumulate each beneficiary value share during current transfer
	// value - total value during current round of transfer
	function __split(uint[] memory values, uint[] shares, uint idx, uint value) internal {
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
