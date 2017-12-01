module.exports = async function(deployer, network, accounts) {
	const Transfers = artifacts.require("./lib/Transfers");
	const Accumulator = artifacts.require("./SharedAccumulator");
	const Transfer = artifacts.require("./SharedTransfer");
	const Token = artifacts.require("./token/ConfigurableERC20");
	const Crowdsale = artifacts.require("./token/OpenCrowdsale");

	await deployer.deploy(Transfers);
	await deployer.link(Transfers, Accumulator);
	await deployer.link(Transfers, Transfer);

	await deployer.deploy(
		Accumulator,
		[
			accounts[1],
			accounts[2],
			accounts[3]
		],
		[
			6, 2, 1, // shares under 0.01 ETH
			1, 6, 2, // shares between 0.01 and 0.02 ETH
			2, 1, 6  // shares over 0.02 ETH
		],
		[
			10000000000000000, // 0.01 ETH
			20000000000000000, // 0.02 ETH
			0
		]
	);
	const accumulator = Accumulator.address;

	await deployer.deploy(
		Transfer,
		[
			accounts[1],
			accounts[2],
			accounts[3]
		],
		[
			6, 2, 1,
			1, 6, 2,
			2, 1, 6
		],
		[
			10000000000000000, // 0.01 ETH
			20000000000000000, // 0.02 ETH
			0
		]
	);
	const transfer = Accumulator.address;

	await deployer.deploy(
		Token,
		"108",
		"Token 108",
		0,
		400
	);
	const token = Token.address;

	const now = new Date().getTime() / 1000 | 0;

	await deployer.deploy(
		Crowdsale,
		now,
		300,
		5000000000000000, // 0.005 ETH
		100000000000000000, // 0.1 ETH
		500000000000000000, // 0.5 ETH
		0,
		accounts[1],
		token
	);
	const presale = Crowdsale.address;
	await Token.at(token).approve(presale, 100);

	await deployer.deploy(
		Crowdsale,
		now,
		300,
		10000000000000000, // 0.01 ETH
		500000000000000000, // 0.5 ETH
		1000000000000000000, // 1.0 ETH
		0,
		accounts[2],
		token
	);
	const crowdsale = Crowdsale.address;
	await Token.at(token).approve(crowdsale, 100);

	console.log("accumulator: " + accumulator);
	console.log("transfer: " + transfer);
	console.log("token: " + token);
	console.log("presale: " + presale);
	console.log("crowdsale: " + crowdsale);
};
