pragma solidity ^0.4.11;

// the contract splits an incoming value and sends its portions to the addresses provided
contract ValueSplitter {
	// wallet0 will receive numerator/denominator fraction of the funds
	address public wallet0;
	// wallet1 will receive the rest of the funds
	address public wallet1;

	// minimum amount of funds which contract is allowed to process in one transaction
	// can be useful to save on transaction fees
	uint256 public quantum;

	// current balance on the contract
	uint256 public balance;
	// total amount of funds already passed through the contract
	uint256 public proxied;

	// last element in thresholds must be always 0,
	// all 3 arrays must have the same lengths
	uint256[] public thresholds;
	uint256[] public numerators;
	uint256[] public denominators;

	// current split state, see also thresholds, numerators and denominators arrays
	uint256 internal idx = 0;
	uint256 internal nextThreshold = 0;
	uint256 internal currentNumerator = 1;
	uint256 internal currentDenominator = 1;

	function ValueSplitter(
		address _wallet0,
		address _wallet1,
		uint256 _quantum,
		uint256[] _thresholds,
		uint256[] _numerators,
		uint256[] _denominators
	) {
		// validate inputs
		assert(_wallet0 != address(0));
		assert(_wallet1 != address(0));
		assert(_thresholds.length == _numerators.length);
		assert(_thresholds.length == _denominators.length);

		// validate inputs: data in the arrays
		uint256 threshold = 0;
		for(uint256 i = 0; i < _thresholds.length; i++) {
			assert(i == _thresholds.length - 1 && _thresholds[i] == 0 || _thresholds[i] > threshold);
			assert(_numerators[i] <= _denominators[i]);
			assert(_denominators[i] > 0);

			threshold = _thresholds[i];
		}

		// assign the data
		wallet0 = _wallet0;
		wallet1 = _wallet1;
		thresholds = _thresholds;
		numerators = _numerators;
		denominators = _denominators;
		quantum = _quantum;

		// init auxiliary private variables if required
		if(_thresholds.length > 0) {
			nextThreshold = _thresholds[0];
			currentNumerator = _numerators[0];
			currentDenominator = _denominators[0];
		}
	}

	function() payable {
		// total amount available on the contract:
		uint256 total = balance + msg.value;

		if(total < quantum) {
			// there is very little money available on contract, do nothing
			balance += msg.value;
			return;
		}

		// there is enough money available on the contract, do the transfer
		uint256 amount = 0;
		uint256 currentThreshold = proxied;
		// while we're crossing the threshold, calculate the shit
		while(nextThreshold != 0 && proxied + total > nextThreshold) {
			// calculate how much is split using current rate
			amount += (nextThreshold - currentThreshold) / currentDenominator * currentNumerator;
			currentThreshold = nextThreshold;

			// now try to update the rates, if available
			idx++;
			if(thresholds.length > idx) {
				// new rates are available, update
				nextThreshold = thresholds[idx];
				currentNumerator = numerators[idx];
				currentDenominator = denominators[idx];
			}
			else {
				// no new rates available
				nextThreshold = 0;
			}
		}
		// all the thresholds are crossed, calculate the rest
		amount += (total - currentThreshold + proxied) / currentDenominator * currentNumerator;

		// transfer wallet0 funds
		wallet0.transfer(amount);

		// transfer wallet1 funds if any funds left
		if(amount < total) {
			wallet1.transfer(total - amount);
		}

		// update statistics
		proxied += total;
		balance = 0;
	}

}
