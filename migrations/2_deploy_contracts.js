var ada = web3.toWei(1, "kwei");		// 1000
var shannon = web3.toWei(1, "gwei");	// 10^9
var finney = web3.toWei(1, "finney");	// 10^15
var ether = web3.toWei(1, "ether");		// 10^18
var einstein = web3.toWei(1, "grand");	// 10^21

var account1 = '0x03cdA1F3DEeaE2de4C73cfC4B93d3A50D0419C24';
var account2 = '0x25fcb8f929BF278669D575ba1A5aD1893e341069';
var account3 = '0x8f8488f9Ce6F830e750BeF6605137651b84F1835';

var token0 = '0x049277c464f357912f95cc5e4b6627d4bdf947f4';

/*
var ValueSplitter = artifacts.require("./ValueSplitter.sol");
var ValueProxy = artifacts.require("./ValueProxy.sol");
var ValueAccumulator = artifacts.require("./ValueAccumulator.sol");

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
*/

var Token = artifacts.require("./ConfigurableERC20.sol");
var Crowdsale = artifacts.require("./Crowdsale.sol");

module.exports = function(deployer, network) {
	var tokenSupply = shannon; // create 10^9 tokens
	var crowdsaleAmount = ada; // crowdsale only 10^3 tokens

	console.log("deploying token...");
/*
	deployer.deploy(
		Token,
		"shannon",
		"shannon token",
		0,	// tokens are indivisible
		tokenSupply
	).then(function() {
*/
		var tokenAddress = token0; // Token.address;
		console.log("token deployed, address: " + tokenAddress);
		console.log("deploying crowdsale...");
		deployer.deploy(
			Crowdsale,
			web3.eth.blockNumber,	// crowdsale start block - current block
			257,					// crowdsale ends in 1hr (257 blocks)
			3 * ether,		// soft cap
			10 * ether,		// hard cap
			ether,			// quantum
			10 * finney,	// token price
			tokenAddress,	// token to sell
			account1		// beneficiary
		).then(function() {
			console.log("crowdsale deployed, address: " + Crowdsale.address);
			console.log("transferring " + crowdsaleAmount + " the tokens to crowdsale...");
			Token.at(tokenAddress).transfer(Crowdsale.address, crowdsaleAmount).then(function(result) {
				console.log(crowdsaleAmount + " tokens (" + tokenAddress + ") successfully transferred to crowdsale " + Crowdsale.address);
				// console.log(result); // too much output
			}).catch(function(e) {
				console.error("ERROR! unable to transfer " + crowdsaleAmount + " tokens (" + tokenAddress + ") to crowdsale " + Crowdsale.address);
				console.error(e);
			});
		});
//	});
};
