pragma solidity ^0.4.0;


// D.H.A.R.M.A. Initiative Swan Protocol
// The protocol must be executed every 108 minutes
// Failure to do so releases all the value to the last executor
contract SwanProtocol {
	// value of the countdown timer, 108 minutes = 4 + 8 + 15 + 16 + 23 + 42
	uint public countdown = 6480;

	// Failing to execute the button sequence before the last 4 minutes
	// of countdown pass results in the sequence of actions described below:

	// at the 4 minute mark, a steady alarm beep signals, and continues for the next 3 minutes
	uint public sequence1 = 240;

	// at the 1-minute mark, an intense alarm signals, and continues for the next 50 seconds
	uint public sequence2 = 60;

	// at the 10-second mark, for 20 seconds, the same alarm signals at a much faster rate
	uint public sequence3 = 10;

	// During the last 10 seconds, Egyptian hieroglyphs flipped in position of the timer numbers

	// last time protocol was executed
	uint public timestamp;

	// last executor of the protocol
	address public executor;

	// number of times protocol was executed
	uint public cycle;

	// minimum value required to execute the protocol
	uint public threshold;

	function SwanProtocol(uint _threshold) {
		threshold = _threshold;
		timestamp = now;
		executor = msg.sender;
	}

	// execute the protocol
	function execute() payable {
		// validate inputs and protocol state
		// value received must be greater or equal to threshold
		require(msg.value >= threshold);
		// there is enough time left to execute the protocol
		assert(now < timestamp + countdown);

		// update the protocol state
		timestamp = now;
		executor = msg.sender;
		cycle++;
	}

	// withdraws the reward to the last executor
	function withdraw() {
		// check if protocol terminated
		require(now >= timestamp + countdown);

		// transfer the reward back to last executor
		executor.transfer(this.balance);
	}
}
