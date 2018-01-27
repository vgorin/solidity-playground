const FixedERC20 = artifacts.require("./token/FixedERC20.sol");
const ConfigurableERC20 = artifacts.require("./token/ConfigurableERC20.sol");

contract('FixedERC20', function(accounts) {
	it("basic ERC20: totalSupply, transfer, balanceOf", async function() {
		const token = await FixedERC20.new(
			247
		);
		assert.equal((await token.totalSupply()).toNumber(), 247, "incorrect totalSupply");
		assert.equal((await token.balanceOf(accounts[0])).toNumber(), 247, "incorrect balanceOf");
		await token.transfer(accounts[1], 17);
		assert.equal((await token.balanceOf(accounts[1])).toNumber(), 17, "incorrect transfer/balanceOf");
	});

	it("extended ERC20: approve, allowance, transferFrom", async function() {
		const token = await FixedERC20.new(
			247
		);
		await token.approve(accounts[1], 17);
		assert.equal((await token.allowance(accounts[0], accounts[1])).toNumber(), 17, "incorrect approve/allowance");
		await token.transferFrom.sendTransaction(accounts[0], accounts[1], 17, {from: accounts[1]});
		assert.equal((await token.balanceOf(accounts[1])).toNumber(), 17, "incorrect transferFrom/balanceOf");
	});
});
contract('ConfigurableERC20', function(accounts) {
	it("symbol, name, decimals", async function() {
		const token = await ConfigurableERC20.new(
			"Token Symbol",
			"Token Name",
			0,
			247
		);
		assert.equal(await token.symbol(), "Token Symbol", "incorrect symbol");
		assert.equal(await token.name(), "Token Name", "incorrect name");
		assert.equal((await token.decimals()).toNumber(), 0, "incorrect symbol");
	});
});
