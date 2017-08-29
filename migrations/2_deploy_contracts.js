var ada = web3.toWei(1, "kwei");		// 1000
var shannon = web3.toWei(1, "gwei");	// 10^9
var finney = web3.toWei(1, "finney");	// 10^15
var ether = web3.toWei(1, "ether");		// 10^18
var einstein = web3.toWei(1, "grand");	// 10^21

var account1 = '0x03cdA1F3DEeaE2de4C73cfC4B93d3A50D0419C24';
var account2 = '0x25fcb8f929BF278669D575ba1A5aD1893e341069';
var account3 = '0x8f8488f9Ce6F830e750BeF6605137651b84F1835';

var token0 = '0xe3a303f644221b1b805cc8a6fa8877da7ae4b668';

var ValueShare = artifacts.require("./ValueShare.sol");
var Token = artifacts.require("./ConfigurableERC20.sol");
var Crowdsale = artifacts.require("./Crowdsale.sol");

module.exports = function(deployer, network) {
	deployer.deploy(
		ValueShare,
		[account1, account2, account3],	// beneficiaries
		[1, 1, 1],						// shares
		[0],							// thresholds
		0								// quantum
	);
/*
	deployer.deploy(
		Token,
		"CML",
		"CML Token",
		0,	// tokens are indivisible
		tokenSupply
	).then(function() {
	var tokenSupply = shannon; // create 10^9 tokens
	var crowdsaleAmount = ada; // crowdsale only 10^3 tokens
	var tokenAddress = token0; //Token.address;
		deployer.deploy(
			Crowdsale,
			web3.eth.blockNumber,	// crowdsale start block is next block
			21,						// crowdsale ends in 5min (21 blocks)
			10 * finney,	// token price
			3 * ether,		// soft cap
			10 * ether,		// hard cap
			ether,			// quantum
			account1,		// beneficiary
			tokenAddress,	// token to sell (used for open crowdsale)
			"CML0",	// token symbol (used for closed crowdsale)
			"CML Token 0",	// token name (used for closed crowdsale)
			0 	// token decimals (used for closed crowdsale)
		).then(function() {
			var crowdsaleAddress = Crowdsale.address;
			Token.at(tokenAddress).transfer(
				crowdsaleAddress,
				crowdsaleAmount
			).then(function(result) {
				console.log(crowdsaleAmount + " tokens (" + tokenAddress + ") successfully allocated for crowdsale " + crowdsaleAddress);
				// console.log(result); // too much output
			}).catch(function(e) {
				console.error("ERROR! Unable to allocate " + crowdsaleAmount + " tokens (" + tokenAddress + ") for crowdsale " + crowdsaleAddress);
				console.error(e);
			});
		}).catch(function(e) {
			console.error("ERROR! Crowdsale deployment failed!");
			console.error(e);
		});
	});
*/
};

