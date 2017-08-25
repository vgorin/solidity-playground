pragma solidity ^0.4.11;

// Limited version of ERC20
contract Transferable {
	function totalSupply() constant returns (uint256 totalSupply);
	function balanceOf(address _owner) constant returns (uint256 balance);
	function transfer(address _to, uint256 _value) returns (bool success);

	event Transfer(address indexed _from, address indexed _to, uint256 _value);
}
