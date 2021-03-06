pragma solidity 0.4.18;

// ERC: Token standard #20, https://github.com/ethereum/eips/issues/20
contract ERC20 {
	function totalSupply() public constant returns (uint _totalSupply);
	function balanceOf(address _owner) public constant returns (uint balance);
	function transfer(address _to, uint _value) public returns (bool success);
	function transferFrom(address _from, address _to, uint _value) public returns (bool success);
	function approve(address _spender, uint _value) public returns (bool success);
	function allowance(address _owner, address _spender) public constant returns (uint remaining);

	event Transfer(address indexed _from, address indexed _to, uint _value);
	event Approval(address indexed _owner, address indexed _spender, uint _value);
}
