const acc = [
	"0x03cdA1F3DEeaE2de4C73cfC4B93d3A50D0419C24",
	"0x25fcb8f929bf278669d575ba1a5ad1893e341069",
	"0x8f8488f9ce6f830e750bef6605137651b84f1835",
	"0x46c3fbed2c66ba8d7af7e2fc72d535798400d3f5"
];

module.exports = async function(deployer, network, accounts) {
/*
	const Transfers = artifacts.require("./lib/Transfers");
	const Accumulator = artifacts.require("./SharedAccumulator");
	const Transfer = artifacts.require("./SharedTransfer");
*/
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

	const totalSupply = 11788618;

	const offset0 = new Date('2018-01-18T00:50').getTime() / 1000 | 0;
	const length0 = 600;
	const price0 = 2000000000000000; // 2 finney (0.002 ether)
	const soft0 = 0;
	const hard0 = 2666666000000000000000; // 2 666.666 ether
	const tokens0 = 1333333;
	const quantum0 = 0;

	const offset1 = new Date('2018-01-18T00:50').getTime() / 1000 | 0;
	const length1 = 600;
	const price1 = 3000000000000000; // 3 finney (0.003 ether)
	const soft1 = 0;
	const hard1 = 20000001000000000000000; // 20 000.001 ether
	const tokens1 = 6666667;
	const quantum1 = 0;

	const offset2 = new Date('2018-01-18T00:50').getTime() / 1000 | 0;
	const length2 = 600;
	const price2 = 4000000000000000; // 4 finney (0.004 ether)
	const soft2 = 0;
	const hard2 = 6666668000000000000000; // 6 666.668 ether
	const tokens2 = 1666667;
	const quantum2 = 0;

	const digits = 18;
	const k = Math.pow(10, digits);
	const p = 10000; // should be 1 for production

	await deployer.deploy(
		Token,
		"TS3",
		"Test3",
		digits,
		totalSupply * k
	);
	const token = Token.address;

	await deployer.deploy(
		Crowdsale,
		offset0,
		length0,
		price0 / p,
		soft0 / p,
		hard0 / p,
		quantum0,
		accounts[0],
		token
	);
	const presale = Crowdsale.address;
	await Token.at(token).approve(presale, tokens0 * k);

	await deployer.deploy(
		Crowdsale,
		offset1,
		length1,
		price1 / p,
		soft1 / p,
		hard1 / p,
		quantum1,
		accounts[0],
		token
	);
	const crowdsale1 = Crowdsale.address;
	await Token.at(token).approve(crowdsale1, tokens1 * k);

	await deployer.deploy(
		Crowdsale,
		offset2,
		length2,
		price2 / p,
		soft2 / p,
		hard2 / p,
		quantum2,
		accounts[0],
		token
	);
	const crowdsale2 = Crowdsale.address;
	await Token.at(token).approve(crowdsale2, tokens2 * k);


	const now = new Date().getTime() / 1000 | 0;
	console.log("current timestamp: " + now);
	console.log("presale timeframe: " + offset0 + " - " + (offset0 + length0));
	console.log("crowdsale1 timeframe: " + offset1 + " - " + (offset1 + length1));
	console.log("crowdsale2 timeframe: " + offset2 + " - " + (offset2 + length2));
/*
	console.log("accumulator: " + accumulator);
	console.log("transfer: " + transfer);
*/
	console.log("token: " + token);
	console.log("presale: " + presale);
	console.log("crowdsale1: " + crowdsale1);
	console.log("crowdsale2: " + crowdsale2);
};
