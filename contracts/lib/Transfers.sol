pragma solidity 0.4.18;

import '../token/ERC20.sol';

// Contains value transfer related utility functions
library Transfers {
	// base structure for storing config and current state
	struct Shared {
		address[] beneficiaries; // config, constant
		uint[] shares; // config, constant
		uint[] thresholds; // config, constant
		mapping(address => uint) balances;  // status
		uint balance; // status: sum of all balances
		uint transferred; // status: current threshold value
		uint idx; // status: current threshold index
	}

	// used to validate config parameters used in sharedTransfer
	function create(address[] beneficiaries, uint[] shares, uint[] thresholds) internal returns (Shared) {
		// total number of beneficiaries, used a lot in the code, shorten it
		uint n = beneficiaries.length;

		// basic validation
		require(n > 0);
		require(n < 32); // protect from 'DoS with Block Gas Limit'
		require(shares.length > 0);
		require(shares.length == thresholds.length * n);

		// in-depth validation of beneficiaries
		for(uint i = 0; i < n; i++) {
			require(beneficiaries[i] != address(0));
		}

		// yes, this stupid language allows to use i though it was defined in 'for loop' scope
		i = 0; // just need to reset it, cause it contains beneficiaries.length - 1 now
		// perform in-depth validation of thresholds
		for(uint t = 0; i < thresholds.length - 1; t = thresholds[i++]) {
			require(t < thresholds[i]); // array must be monotonously growing
		}
		require(thresholds[i] == 0); // except the last element which must be zero

		// in-depth check of shares array
		for(i = 0; i < shares.length; i++) {
		  // shares shouldn't contain big numbers - will affect precision heavily
			require(shares[i] < 2 << 15);

			// make sure shares array doesn't contain zero sums -  future division zero by zero
			if(i / n * n == i) { // division reminder - 'nice', isn't it?
				require(__totalShare(shares, i / n, n) > 0);
			}
		}

		// create shared transfer struct
		return Shared(beneficiaries, shares, thresholds, 0, 0, 0);
	}

	// approves shares transfers to beneficiaries according to parameters specified
	// similar to append except it takes whole contract balance as an argument
	function update(Shared storage t, uint balance) internal {
		require(balance > t.balance);
		append(t, balance - t.balance);
	}

	// approves shares transfers to beneficiaries according to parameters specified
	function append(Shared storage t, uint value) internal {
		// validations
		require(value > 0); // input parameter check
		assert(t.transferred + value > t.transferred); // overflow check
		assert(t.balance + value > t.balance); // overflow check

		// define auxiliary variables
		uint n = t.beneficiaries.length; // number of beneficiaries
		uint[] memory values = new uint[](n); // value to allocate for each of beneficiaries

		// cross the thresholds
		for(
			uint current = t.transferred; // current active threshold
			t.thresholds[t.idx] != 0 && t.transferred + value > t.thresholds[t.idx];
			current = t.thresholds[t.idx++] // update both current threshold and idx
		) {
			// calculate each beneficiary value share in between thresholds
			__split(values, t.shares, t.idx, t.thresholds[t.idx] - current);
		}

		// all the thresholds are crossed, calculate the rest
		__split(values, t.shares, t.idx, value - current + t.transferred);

		// update status
		t.transferred += value;
		t.balance += value;

		// approve the values transfers
		for(uint i = 0; i < n; i++) {
			__transfer(t, t.beneficiaries[i], values[i]);
		}
	}

	// performs actual value transfer to all beneficiaries, should be called after approveValue
	function withdrawAll(Shared storage t) internal {
		// ensure balance is positive
		assert(t.balance > 0);
		// perform withdrawal
		for(uint i = 0; i < t.beneficiaries.length; i++) {
			address beneficiary = t.beneficiaries[i];
			if(t.balances[beneficiary] > 0) {
				withdraw(t, beneficiary);
			}
		}
	}

	// performs actual value transfer to all beneficiaries, should be called after approveValue
	function withdraw(Shared storage t, address beneficiary) internal {
		uint value = t.balances[beneficiary];

		// validations
		require(value > 0); // input parameter check
		assert(t.balance >= value); // structure state check + overflow check

		// update contract state
		t.balances[beneficiary] = 0;
		t.balance -= value;

		// do the transfer
		beneficiary.transfer(value);
	}

	// approves value transfer for beneficiary
	function __transfer(Shared storage t, address beneficiary, uint value) private {
		assert(t.balances[beneficiary] + value > t.balances[beneficiary]); // overflow check
		t.balances[beneficiary] += value; // perform operation
	}

	// n - number of beneficiaries, values array length
	// values - array to accumulate each beneficiary value share during current transfer
	// value - total value during current round of transfer
	function __split(uint[] memory values, uint[] shares, uint idx, uint value) private {
		// number of beneficiaries
		uint n = values.length;

		// temporary variable for simple loops
		uint i;

		// temp variables to fix rounding off discrepancy
		uint v0 = 0;
		uint vi;

		// total share
		uint share = __totalShare(shares, idx, n);

		// calculate each beneficiary value share
		for(i = 0; i < n; i++) {
			vi = value / share * shares[idx * n + i]; // i-th for current round
			values[i] += vi; // increment beneficiary's share
			v0 += vi; // total for current round
		}

		// fix rounding off discrepancy
		values[0] += value - v0;
	}

	// calculates the sum of shares in range [idx * n, (idx + 1) * n)
	function __totalShare(uint[] shares, uint idx, uint n) private returns(uint share) {
		// calculate total share for round 'idx'
		for(uint i = 0; i < n; i++) {
			share += shares[idx * n + i];
		}
	}

}
