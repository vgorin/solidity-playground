pragma solidity ^0.4.11;

// ERC20 API subset
// marker interface, can be used for ERC20 tokens, addresses
contract Transferable {
	// ERC20.transfer
	function transfer(address _to, uint _value) returns (bool success);
}
