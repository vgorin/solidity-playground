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

var acc0 = '0x20bf25e46a40fb64fde7aa8fc3170549a7feab37';

var token0 = '0x8c10b0d326c394820eaee137a4936328d4d5dc0c';

// crowdsale settings
var preSale = new Crowdsale(
	web3.eth.blockNumber, // offset
	21, // length
	5 * finney, // rate
	0, // softCap
	ether, // hardCap
	0 // quantum
);

// crowdsale settings
var crowdsale = new Crowdsale(
	web3.eth.blockNumber, // offset
	21, // length
	10 * finney, // rate
	ether, // softCap
	10 * ether, // hardCap
	0 // quantum
);

// total token supply
var supply = 100 * (preSale.amount() + crowdsale.amount());

module.exports = function(deployer, network) {
	var Transfers = artifacts.require("./lib/Transfers.sol");
	var Accumulator = artifacts.require("./SharedAccumulator.sol");
	var Transfer = artifacts.require("./SharedTransfer.sol");
	var Token = artifacts.require("./token/ConfigurableERC20.sol");
	var Crowdsale = artifacts.require("./Crowdsale.sol");
	var Redemption = artifacts.require("./Redemption.sol");


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

	deployer.deploy(
		Token,
		"TK",
		"Token",
		0, // tokens are indivisible
		supply
	);

	deployCrowdsale(deployer, Crowdsale, Token, preSale);
	deployCrowdsale(deployer, Crowdsale, Token, crowdsale);

	deployer.deploy(
		Redemption,
		20 * finney,
		token0
	);

};

function deployCrowdsale(deployer, crowdsaleContract, tokenContract, crowdsale) {
	deployer.deploy(
		crowdsaleContract,
		crowdsale.offset,
		crowdsale.length,
		crowdsale.rate,
		crowdsale.softCap,
		crowdsale.hardCap,
		crowdsale.quantum,
		acc0, // beneficiary
		token0, // token to sell (used for open crowdsale)
		"", // token symbol (used for closed crowdsale)
		"", // token name (used for closed crowdsale)
		0  // token decimals (used for closed crowdsale)
	).then(function() {
		var crowdsaleAddress = crowdsaleContract.address;
		tokenContract.at(token0).transfer(
			crowdsaleAddress,
			crowdsale.amount()
		).then(function(result) {
			console.log(crowdsale.amount() + " tokens (" + token0 + ") successfully allocated for crowdsale " + crowdsaleAddress);
			// console.log(result); // too much output
		}).catch(function(e) {
			console.error("ERROR! Unable to allocate " + crowdsale.amount() + " tokens (" + token0 + ") for crowdsale " + crowdsaleAddress);
			console.error(e);
		});
	}).catch(function(e) {
		console.error("ERROR! Crowdsale deployment failed!");
		console.error(e);
	});
}

function Crowdsale(offset, length, rate, softCap, hardCap, quantum) {
	this.offset = offset;
	this.length = length;
	this.rate = rate;
	this.softCap = softCap;
	this.hardCap = hardCap;
	this.quantum = quantum;

	this.amount = function() {
		return this.hardCap / this.rate;
	}
}
