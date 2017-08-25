pragma solidity ^0.4.11;

import './Transferable.sol';

contract TransferableToken is Transferable {

	// Balances for each account
	mapping(address => uint256) balances;

	/**
	* @dev Gets the balance of the specified address.
	* @param _owner The address to query the the balance of.
	* @return An uint256 representing the amount owned by the passed address.
	*/
	// What is the balance of a particular account?
	function balanceOf(address _owner) constant returns (uint256 balance) {
		return balances[_owner];
	}

	// Transfer the balance from owner's account to another account
	/**
	* @dev transfer token for a specified address
	* @param _to The address to transfer to.
	* @param _value The amount to be transferred.
	*/
	function transfer(address _to, uint256 _value) returns (bool) {
		// check input parameter(s)
		assert(_value > 0); // non-negative transfer
		assert(balances[_to] + _value > balances[_to]); // overflow check
		require(_value <= balances[msg.sender]); // enough funds

		// perform the operation
		balances[msg.sender] -= _value;
		balances[_to] += _value;

		// log the successful transfer
		Transfer(msg.sender, _to, _value);

		// operation successful, if case of an error we already failed fast
		return true;
	}

}
