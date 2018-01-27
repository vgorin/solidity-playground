const Token = artifacts.require("./token/ConfigurableERC20.sol");
const Crowdsale = artifacts.require("./NamedCrowdsale.sol");

contract('OpenCrowdsale', function(accounts) {
	it("invest, refund", async function() {
		const token = await Token.new("BSL", "Basil Token", 0, 11788618);
		const crowdsale = await Crowdsale.new(
			"Basil Token Refund",
			new Date().getTime() / 1000 | 0,
			300,
			200000000000,
			66666600000000000,
			266666600000000000,
			0,
			accounts[7],
			token.address
		);
		await token.approve(crowdsale.address, 1333333);
		await crowdsale.invest.sendTransaction({value: 200000000000, from: accounts[1]});
		assert.equal((await token.balanceOf(accounts[1])).toNumber(), 1, "incorrect invest");
		web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [300], id: 0});
		await token.approve.sendTransaction(crowdsale.address, 1, {from: accounts[1]});
		await crowdsale.refund.sendTransaction({from: accounts[1]});
		assert.equal((await token.balanceOf(accounts[0])).toNumber(), 11788618, "incorrect refund");
	});
	it("invest, withdraw", async function() {
		const token = await Token.new("BSL", "Basil Token", 0, 11788618);
		const crowdsale = await Crowdsale.new(
			"Basil Token Withdraw",
			300 + new Date().getTime() / 1000 | 0,
			300,
			200000000000,
			66666600000000000,
			266666600000000000,
			266666600000000000,
			accounts[7],
			token.address
		);
		await token.approve(crowdsale.address, 1333333);
		await crowdsale.invest.sendTransaction({value: 66666600000000000, from: accounts[1]});
		assert.equal((await token.balanceOf(accounts[1])).toNumber(), 333333, "incorrect invest");
		web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [300], id: 0});
		await crowdsale.withdraw();
		assert.equal((await web3.eth.getBalance(accounts[7])).toNumber(), 100066666600000000000, "incorrect withdraw");
	});
});
