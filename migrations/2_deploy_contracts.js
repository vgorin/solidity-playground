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

var acc0 = '0x04b9bf8144bf7c26063645372b2d4f8bf630ad84';

var token0 = '0x462d2bf198865371d3043259d175770b3dc4284a';

// crowdsale settings
var pre_sale = new CrowdsaleConfig(
	1512086400, // 12/01/2017 @ 12:00am (UTC)
	86400, // 1 day
	5 * finney, // rate
	0, // softCap
	10 * ether, // hardCap
	0 // quantum
);

// crowdsale settings
var crowdsale = new CrowdsaleConfig(
	1512432000, // 12/05/2017 @ 12:00am (UTC)
	1209600, // 14 days
	10 * finney, // rate
	10 * ether, // softCap
	20 * ether, // hardCap
	0 // quantum
);

// total token supply
var supply = pre_sale.amount() + crowdsale.amount();

module.exports = function(deployer, network) {
	var Transfers = artifacts.require("./lib/Transfers.sol");
	var Accumulator = artifacts.require("./SharedAccumulator.sol");
	var Transfer = artifacts.require("./SharedTransfer.sol");
	var Token = artifacts.require("./token/ConfigurableERC20.sol");
	var Crowdsale = artifacts.require("./OpenCrowdsale.sol");
	var Redemption = artifacts.require("./Redemption.sol");


	deployer.deploy(Transfers);
	deployer.link(Transfers, Accumulator);

	deployer.deploy(
		Accumulator,
		[account1, account2, account3],	// beneficiaries
		[
			95, 4, 1,	// shares before 1 ether
			245, 4, 1,	// shares before 2 ether
			495, 4, 1	// shares after 2 ether
		],
		[5 * ether, 10 * ether, 0]	// thresholds
	).then(function() {
		acc0 = Accumulator.address;
	});

	deployer.deploy(
		Token,
		"BSL",
		"Basil Token",
		0, // tokens are indivisible
		supply
	).then(function() {
		token0 = Token.address;
	});

	deployCrowdsale(deployer, Crowdsale, Token.at(token0), pre_sale);
	deployCrowdsale(deployer, Crowdsale, Token.at(token0), crowdsale);

	deployer.deploy(
		Redemption,
		20 * finney,
		token0
	);

};

function deployCrowdsale(deployer, contract, token, config) {
	deployer.deploy(
		contract,
		config.offset,
		config.length,
		config.rate,
		config.softCap,
		config.hardCap,
		config.quantum,
		acc0, // beneficiary
		token.address // token to sell
	).then(function() {
		var addr = contract.address;
		token.transfer(
			addr,
			config.amount()
		).then(function(result) {
			console.log(config.amount() + " tokens (" + token.address + ") successfully allocated for crowdsale " + addr);
			// console.log(result); // too much output
		}).catch(function(e) {
			console.error("ERROR! Unable to allocate " + config.amount() + " tokens (" + token.address + ") for crowdsale " + addr);
			console.error(e);
		});
	}).catch(function(e) {
		console.error("ERROR! Crowdsale deployment failed!");
		console.error(e);
	});
}

function CrowdsaleConfig(offset, length, rate, softCap, hardCap, quantum) {
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
