var Crowdsale = artifacts.require("./Crowdsale.sol");
var ValueSplitter = artifacts.require("./ValueSplitter.sol");
var ValueProxy = artifacts.require("./ValueProxy.sol");
var ValueAccumulator = artifacts.require("./ValueAccumulator.sol");

var account1 = '0x03cdA1F3DEeaE2de4C73cfC4B93d3A50D0419C24';
var account2 = '0x25fcb8f929BF278669D575ba1A5aD1893e341069';
var account3 = '0x8f8488f9Ce6F830e750BeF6605137651b84F1835';

var ether = web3.toWei(1, "ether");

module.exports = function(deployer, network) {
	deployer.deploy(ValueAccumulator).then(function() {
		deployer.deploy(ValueProxy, ValueAccumulator.address);
	});
	deployer.deploy(ValueProxy, account1).then(function() {
		deployer.deploy(ValueProxy, ValueProxy.address);
	});
	deployer.deploy(
		ValueSplitter,
		account2,
		account3,
		0,
		[0],
		[4],
		[5]
	);
	deployer.deploy(
		ValueSplitter,
		account1,
		'0xdab70c0fa14076c7e2341fb341062a11df8e4a68',
		0,
		[2 * ether, 10 * ether, 0],
		[19, 49, 99],
		[20, 50, 100]
	);
};
