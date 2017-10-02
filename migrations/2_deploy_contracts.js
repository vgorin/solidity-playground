Number.prototype.kwei = function () {
	return web3.toWei(this, "kwei");	// 1000
};

Number.prototype.mwei = function () {
	return web3.toWei(this, "mwei");	// 10^6
};
Number.prototype.gwei = function () {
	return web3.toWei(this, "gwei");	// 10^9
};

Number.prototype.szabo = function () {
	return web3.toWei(this, "szabo");	// 10^12
};
Number.prototype.finney = function () {
	return web3.toWei(this, "finney");	// 10^15
};

Number.prototype.ether = function () {
	return web3.toWei(this, "ether");	// 10^18
};
Number.prototype.einstein = function () {
	return web3.toWei(this, "grand");	// 10^21
};

Number.prototype.k = function () {
	return this;// / 10..kwei();
};

var account1 = '0x03cdA1F3DEeaE2de4C73cfC4B93d3A50D0419C24';
var account2 = '0x25fcb8f929BF278669D575ba1A5aD1893e341069';
var account3 = '0x8f8488f9Ce6F830e750BeF6605137651b84F1835';

var acc0 = '0x04b9bf8144bf7c26063645372b2d4f8bf630ad84';

var token0 = '0x462d2bf198865371d3043259d175770b3dc4284a';

// crowdsale settings
var pre_sale = new CrowdsaleConfig(
	1512086400, // 12/01/2017 @ 12:00am (UTC)
	86400, // 1 day
	5..finney(), // rate
	0, // softCap
	10..einstein().k(), // hardCap
	0 // quantum
);

// crowdsale settings
var crowdsale = new CrowdsaleConfig(
	1512432000, // 12/05/2017 @ 12:00am (UTC)
	1209600, // 14 days
	10..finney(), // rate
	10..einstein().k(), // softCap
	90..einstein().k(), // hardCap
	0 // quantum
);

// total token supply
var supply = 2 * (pre_sale.amount() + crowdsale.amount());

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
			95, 4, 1,	// shares before t0
			245, 4, 1,	// shares before t1
			495, 4, 1	// shares after t1
		],
		[
			7..einstein().k(),	// t0
			35..einstein().k(),	// t1
			0
		]
	).then(function() {
		acc0 = Accumulator.address;
	});

	deployer.deploy(
		Token,
		"BSL",
		"Basil Token",
		18,
		supply
	).then(function() {
		token0 = Token.address;
	});

	deployCrowdsale(deployer, Crowdsale, Token.at(token0), pre_sale);
	deployCrowdsale(deployer, Crowdsale, Token.at(token0), crowdsale);

	deployer.deploy(
		Redemption,
		20..finney,
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
