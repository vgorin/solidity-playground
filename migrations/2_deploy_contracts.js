var ada = web3.toWei(1, "kwei");		// 1000
var babbage = web3.toWei(1, "mwei");	// 10^6
var shannon = web3.toWei(1, "gwei");	// 10^9
var szabo = web3.toWei(1, "szabo");		// 10^12
var finney = web3.toWei(1, "finney");	// 10^15
var ether = web3.toWei(1, "ether");		// 10^18
var einstein = web3.toWei(1, "grand");	// 10^21

var account1 = '0x03cdA1F3DEeaE2de4C73cfC4B93d3A50D0419C24';
var account2 = '0x25fcb8f929BF278669D575ba1A5aD1893e341069';
var account3 = '0x8f8488f9Ce6F830e750BeF6605137651b84F1835';

var accumulator = '0x650c2d51dd04a70f1223ca83eefeccc8dec72519';

var token0 = '0xdbe4d5fd70493c159b5c15c1d9c7bf3afce838e1';

var Transfers = artifacts.require("./lib/Transfers.sol");
var Accumulator = artifacts.require("./SharedAccumulator.sol");
var Transfer = artifacts.require("./SharedTransfer.sol");
var Token = artifacts.require("./token/ConfigurableERC20.sol");
var Crowdsale = artifacts.require("./Crowdsale.sol");
var Redemption = artifacts.require("./Redemption.sol");

// crowdsale settings
var preSale = {
	length: 21, // crowdsale lasts for 5min (21 blocks)
	rate: 5 * finney, // token price
	softCap: 0,
	hardCap: ether,
	quantum: 0,
	amount: 200
};

// crowdsale settings
var crowdsale = {
	length: 21, // crowdsale lasts for 5min (21 blocks)
	rate: 10 * finney, // token price
	softCap: ether,
	hardCap: 10 * ether,
	quantum: 0,
	amount: 1000
};

// total token supply
var supply = preSale.amount + crowdsale.amount;

module.exports = function(deployer, network) {
/*
	deployer.deploy(Transfers);
	deployer.link(Transfers, Transfer);
	deployer.deploy(
		Transfer,
		[account1, account2, account3],	// beneficiaries
		[
			95, 4, 1,	// shares before 1 ether
			245, 4, 1,	// shares before 2 ether
			495, 4, 1	// shares after 2 ether
		],
		[ether, 2 * ether, 0]	// thresholds
	);
	deployer.link(Transfers, Accumulator);
	deployer.deploy(
		Accumulator,
		[account1, account2, account3],	// beneficiaries
		[
			95, 4, 1,	// shares before 1 ether
			245, 4, 1,	// shares before 2 ether
			495, 4, 1	// shares after 2 ether
		],
		[ether, 2 * ether, 0]	// thresholds
	);
*/

/*
	deployer.deploy(
		Token,
		"TK",
		"Token",
		0, // tokens are indivisible
		supply
	);
*/

	// deployCrowdsale(deployer, preSale);
	// deployCrowdsale(deployer, crowdsale);

	deployer.deploy(
		Redemption,
		20 * finney,
		token0
	);
};

function deployCrowdsale(deployer, crowdsale) {
	deployer.deploy(
		Crowdsale,
		web3.eth.blockNumber,	// crowdsale start block is next block
		crowdsale.length,					// crowdsale ends in 5min (21 blocks)
		crowdsale.rate,			// token price
		crowdsale.softCap,		// soft cap
		crowdsale.hardCap,		// hard cap
		crowdsale.quantum,		// quantum
		account1,		// beneficiary
		token0,	// token to sell (used for open crowdsale)
		"",	// token symbol (used for closed crowdsale)
		"",	// token name (used for closed crowdsale)
		0 	// token decimals (used for closed crowdsale)
	).then(function() {
		var crowdsaleAddress = Crowdsale.address;
		Token.at(token0).transfer(
			crowdsaleAddress,
			crowdsale.amount
		).then(function(result) {
			console.log(crowdsale.amount + " tokens (" + token0 + ") successfully allocated for crowdsale " + crowdsaleAddress);
			// console.log(result); // too much output
		}).catch(function(e) {
			console.error("ERROR! Unable to allocate " + crowdsale.amount + " tokens (" + token0 + ") for crowdsale " + crowdsaleAddress);
			console.error(e);
		});
	}).catch(function(e) {
		console.error("ERROR! Crowdsale deployment failed!");
		console.error(e);
	});
}
