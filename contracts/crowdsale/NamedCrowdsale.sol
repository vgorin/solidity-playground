pragma solidity ^0.4.0;

import './OpenCrowdsale.sol';

// open crowdsale extension, allows to specify the name for the crowdsale
contract NamedCrowdsale is OpenCrowdsale {
	// name of the crowdsale
	string public name;

	function NamedCrowdsale(
		string _name,
		uint _offset,
		uint _length,
		uint _price,
		uint _softCap,
		uint _hardCap,
		uint _quantum,
		address _beneficiary,
		address _token
	) public OpenCrowdsale(_offset, _length, _price, _softCap, _hardCap, _quantum, _beneficiary, _token) {
		name = _name;
	}
}
