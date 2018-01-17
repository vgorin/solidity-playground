module.exports = async function(deployer, network, accounts) {
	const Transfers = artifacts.require("./lib/Transfers");
	const Accumulator = artifacts.require("./SharedAccumulator");
	const Transfer = artifacts.require("./SharedTransfer");
	const Token = artifacts.require("./token/ConfigurableERC20");
	const Crowdsale = artifacts.require("./token/OpenCrowdsale");

/*
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
*/

	await deployer.deploy(
		Token,
		"TS1",
		"Test1",
		0,
		11788618
	);
	const token = Token.address;

	const now = new Date().getTime() / 1000 | 0;

	await deployer.deploy(
		Crowdsale,
		1516209000,
		600,
		2000000000000000, // 2 finney (0.002 ether)
		0,
		2666666000000000000000, // 2 666.666 ether
		0,
		accounts[1],
		token
	);
	const presale = Crowdsale.address;
	await Token.at(token).approve(presale, 1333333);

	await deployer.deploy(
		Crowdsale,
		1516209900,
		600,
		3000000000000000, // 3 finney (0.003 ether)
		0,
		20000001000000000000000, // 20 000.001 ether
		0,
		accounts[1],
		token
	);
	const crowdsale1 = Crowdsale.address;
	await Token.at(token).approve(crowdsale1, 6666667);

	await deployer.deploy(
		Crowdsale,
		1516210800,
		600,
		4000000000000000, // 3 finney (0.003 ether)
		0,
		6666668000000000000000, // 6 666.668 ether
		0,
		accounts[1],
		token
	);
	const crowdsale2 = Crowdsale.address;
	await Token.at(token).approve(crowdsale2, 1666667);


	console.log("accumulator: " + accumulator);
	console.log("transfer: " + transfer);
	console.log("token: " + token);
	console.log("presale: " + presale);
	console.log("crowdsale1: " + crowdsale1);
	console.log("crowdsale2: " + crowdsale2);
};
