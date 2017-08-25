pragma solidity ^0.4.11;

// value proxy just sends any value it receives to an address provided during contract creation
contract ValueProxy {
	address public proxy;

	function ValueProxy(address _proxy) {
		assert(_proxy != address(0));
		proxy = _proxy;
	}

	function() payable {
		proxy.transfer(msg.value);
	}
}
