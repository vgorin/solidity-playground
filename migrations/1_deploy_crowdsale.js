module.exports = async function(deployer, network, accounts) {
	if (network !== 'development') {
		return;
	}


	const Token = artifacts.require("./token/ConfigurableERC20");
	const Crowdsale = artifacts.require("./NamedCrowdsale");

	const tokenName = "Nagri Token (Staging 1)";
	const symbol = "NGR-1";
	const totalSupply = 11788618;

	const name0 = "Nagri Presale";
	const offset0 = new Date('2018-01-27T12:00').getTime() / 1000 | 0;
	const length0 = 21600;
	const price0 = 2000000000000000; // 2 finney (0.002 ether)
	const soft0 = 0;
	const hard0 = 2666666000000000000000; // 2 666.666 ether
	const tokens0 = 1333333;
	const quantum0 = 0;

	const name1 = "Nagri Crowdsale, Phase 1";
	const offset1 = new Date('2018-01-28T12:00').getTime() / 1000 | 0;
	const length1 = 21600;
	const price1 = 3000000000000000; // 3 finney (0.003 ether)
	const soft1 = 0;
	const hard1 = 20000001000000000000000; // 20 000.001 ether
	const tokens1 = 6666667;
	const quantum1 = 0;

	const name2 = "Nagri Crowdsale, Phase 2";
	const offset2 = new Date('2018-01-29T12:00').getTime() / 1000 | 0;
	const length2 = 21600;
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
		symbol,
		tokenName,
		digits,
		totalSupply * k
	);
	const token = Token.address;

	await deployer.deploy(
		Crowdsale,
		name0,
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
		name1,
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
		name2,
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
	console.log("token: " + token);
	console.log("presale: " + presale);
	console.log("crowdsale1: " + crowdsale1);
	console.log("crowdsale2: " + crowdsale2);
};
