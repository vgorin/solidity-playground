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

const account1 = '0x03cdA1F3DEeaE2de4C73cfC4B93d3A50D0419C24';
const account2 = '0x25fcb8f929BF278669D575ba1A5aD1893e341069';
const account3 = '0x8f8488f9Ce6F830e750BeF6605137651b84F1835';

const acc0 = account1; //'0x13e5e5c56424050d30ae42895d744d3e5f0cb131';

let token0 = '0xe45a4503c9a3495ad49c2160b780615a1fe47eca';

const decimals = 18;
const pow = Math.pow(10, decimals);

// current unix timestamp as described in www.unixtimestamp.com
const now = new Date().getTime() / 1000 | 0;

// crowdsale settings
const pre_sale = new CrowdsaleConfig(
	now, // 1512086400, // 12/01/2017 @ 12:00am (UTC)
	300, // 86400, // 1 day
	5..finney(), // rate
	0, // softCap
	1..ether(), // 10..einstein(), // hardCap
	0 // quantum
);

// crowdsale settings
const crowdsale = new CrowdsaleConfig(
	now + 300, // 1512432000, // 12/05/2017 @ 12:00am (UTC)
	300, // 1209600, // 14 days
	10..finney(), // rate
	1..ether(), // 10..einstein(), // softCap
	9..ether(), // 90..einstein(), // hardCap
	0 // quantum
);

// total token supply
const supply = 2 * (pre_sale.tokens() + crowdsale.tokens());
console.log("total token supply:\t" + supply);
console.log("token decimals: \t" + decimals);
console.log("decimal pow: \t" + pow);
console.log("pre-sale price:\t" + pre_sale.price);
console.log("pre-sale hard cap:\t" + pre_sale.hardCap);
console.log("pre-sale tokens:\t" + pre_sale.tokens());
console.log("crowdsale price:\t" + crowdsale.price);
console.log("crowdsale soft cap:\t" + crowdsale.softCap);
console.log("crowdsale hard cap:\t" + crowdsale.hardCap);
console.log("crowdsale tokens:\t" + crowdsale.tokens());

module.exports = function(deployer, network) {
	const Transfers = artifacts.require("./lib/Transfers.sol");
	const Accumulator = artifacts.require("./SharedAccumulator.sol");
	const Transfer = artifacts.require("./SharedTransfer.sol");
	const Token = artifacts.require("./token/ConfigurableERC20.sol");
	const Crowdsale = artifacts.require("./OpenCrowdsale.sol");
	const Redemption = artifacts.require("./Redemption.sol");


/*
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
			7..einstein(),	// t0
			35..einstein(),	// t1
			0
		]
	).then(function() {
		acc0 = Accumulator.address;
	});
*/

	deployer.deploy(
		Token,
		"BSL",
		"Basil Token",
		decimals,
		supply * pow
	).then(function() {
		token0 = Token.address;
		deployCrowdsale(deployer, Crowdsale, Token.at(token0), pre_sale);
	});

	// deployCrowdsale(deployer, Crowdsale, Token.at(token0), pre_sale);
	// deployCrowdsale(deployer, Crowdsale, Token.at(token0), crowdsale);

/*
	deployer.deploy(
		Redemption,
		20..finney(),
		token0
	);
*/

};

function deployCrowdsale(deployer, contract, token, config) {
	deployer.deploy(
		contract,
		config.offset,
		config.length,
		config.price,
		config.softCap,
		config.hardCap,
		config.quantum,
		acc0, // beneficiary
		token.address // token to sell
	).then(function() {
		const addr = contract.address;
		token.transfer(
			addr,
			config.tokens() * pow
		).then(function(result) {
			console.log(config.tokens() + " tokens (" + token.address + ") successfully allocated for crowdsale " + addr);
			// console.log(result); // too much output
		}).catch(function(e) {
			console.error("ERROR! Unable to allocate " + config.tokens() + " tokens (" + token.address + ") for crowdsale " + addr);
			console.error(e);
		});
	}).catch(function(e) {
		console.error("ERROR! Crowdsale deployment failed!");
		console.error(e);
	});
}

function CrowdsaleConfig(offset, length, price, softCap, hardCap, quantum) {
	this.offset = offset;
	this.length = length;
	this.price = price;
	this.softCap = softCap;
	this.hardCap = hardCap;
	this.quantum = quantum;

	this.tokens = function() {
		return this.hardCap / this.price;
	}
}
