pragma solidity ^0.4.15;

import './ERC20.sol';

// extension of limited transferable token to support ERC20 fully
// ERC20Token is abstract, totalSupply() is not defined
contract ERC20Token is ERC20 {

	// Balances for each account
	mapping(address => uint) balances;

	// Owner of account approves the transfer of an amount to another account
	mapping(address => mapping (address => uint)) allowed;


	/**
	* @dev Gets the balance of the specified address.
	* @param _owner The address to query the the balance of.
	* @return An uint representing the amount owned by the passed address.
	*/
	// What is the balance of a particular account?
	function balanceOf(address _owner) constant returns (uint balance) {
		return balances[_owner];
	}

	// Transfer the balance from owner's account to another account
	/**
	* @dev transfer token for a specified address
	* @param _to The address to transfer to.
	* @param _value The amount to be transferred.
	*/
	function transfer(address _to, uint _value) returns (bool) {
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


	/**
	 * @dev Transfer tokens from one address to another
	 * @param _from address The address which you want to send tokens from
	 * @param _to address The address which you want to transfer to
	 * @param _value uint the amount of tokens to be transfered
	 */
	// Send _value amount of tokens from address _from to address _to
	// The transferFrom method is used for a withdraw workflow, allowing contracts to send
	// tokens on your behalf, for example to "deposit" to a contract address and/or to charge
	// fees in sub-currencies; the command should fail unless the _from account has
	// deliberately authorized the sender of the message via some mechanism
	function transferFrom(address _from, address _to, uint _value) returns (bool) {
		// check input parameter(s)
		assert(_value > 0); // non-negative transfer
		assert(balances[_to] + _value > balances[_to]); // overflow check
		require(_value <= balances[_from]); // enough funds available on account
		require(_value <= allowed[_from][msg.sender]); // enough funds allowed to transfer

		// perform the operation
		allowed[_from][msg.sender] -= - _value;
		balances[_from] -= _value;
		balances[_to] += _value;

		// log the successful transfer
		Transfer(_from, _to, _value);

		// operation successful, if case of an error we already failed fast
		return true;
	}

	/**
	 * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
	 * @param _spender The address which will spend the funds.
	 * @param _value The amount of tokens to be spent.
	 */
	// Allow _spender to withdraw from your account, multiple times, up to the _value amount.
	// If this function is called again it overwrites the current allowance with _value.
	function approve(address _spender, uint _value) returns (bool) {

		// To change the approve amount you first have to reduce the addresses`
		//  allowance to zero by calling `approve(_spender, 0)` if it is not
		//  already 0 to mitigate the race condition described here:
		//  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
		require((_value == 0) || (allowed[msg.sender][_spender] == 0));

		// perform the operation
		allowed[msg.sender][_spender] = _value;

		// log the successful approval
		Approval(msg.sender, _spender, _value);

		// operation successful, if case of an error we already failed fast
		return true;
	}

	/**
	 * @dev Function to check the amount of tokens that an owner allowed to a spender.
	 * @param _owner address The address which owns the funds.
	 * @param _spender address The address which will spend the funds.
	 * @return A uint specifying the amount of tokens still available for the spender.
	 */
	function allowance(address _owner, address _spender) constant returns (uint remaining) {
		return allowed[_owner][_spender];
	}

}
