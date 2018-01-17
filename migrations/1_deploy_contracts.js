const acc = [
	"0x03cdA1F3DEeaE2de4C73cfC4B93d3A50D0419C24",
	"0x25fcb8f929bf278669d575ba1a5ad1893e341069",
	"0x8f8488f9ce6f830e750bef6605137651b84f1835",
	"0x46c3fbed2c66ba8d7af7e2fc72d535798400d3f5"
];

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
			acc[1],
			acc[2],
			acc[3]
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
			acc[1],
			acc[2],
			acc[3]
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

	await deployer.deploy(
		Crowdsale,
		1516206900,
		600,
		2000000000000000, // 2 finney (0.002 ether)
		0,
		266666600000000000, // 0.2666666 ether
		0,
		accounts[0],
		token
	);
	const presale = Crowdsale.address;
	await Token.at(token).approve(presale, 1333333);

	await deployer.deploy(
		Crowdsale,
		1516207500,
		600,
		3000000000000000, // 3 finney (0.003 ether)
		0,
		2000000100000000000, // 2.0000001 ether
		0,
		accounts[0],
		token
	);
	const crowdsale1 = Crowdsale.address;
	await Token.at(token).approve(crowdsale1, 6666667);

	await deployer.deploy(
		Crowdsale,
		1516208100,
		600,
		4000000000000000, // 3 finney (0.003 ether)
		0,
		666666800000000000, // 0.6666668 ether
		0,
		accounts[0],
		token
	);
	const crowdsale2 = Crowdsale.address;
	await Token.at(token).approve(crowdsale2, 1666667);


/*
	console.log("accumulator: " + accumulator);
	console.log("transfer: " + transfer);
*/
	console.log("token: " + token);
	console.log("presale: " + presale);
	console.log("crowdsale1: " + crowdsale1);
	console.log("crowdsale2: " + crowdsale2);
};
