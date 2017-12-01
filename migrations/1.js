module.exports = async function(deployer, network, accounts) {
	const Token = artifacts.require("./token/ConfigurableERC20");
	const Crowdsale = artifacts.require("./token/OpenCrowdsale");

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
		0x03cdA1F3DEeaE2de4C73cfC4B93d3A50D0419C24,
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
		0x03cdA1F3DEeaE2de4C73cfC4B93d3A50D0419C24,
		token
	);

	const crowdsale = Crowdsale.address;

	await Token.at(token).approve(crowdsale, 100);

	console.log("token: " + token);
	console.log("presale: " + presale);
	console.log("crowdsale: " + crowdsale);
};
