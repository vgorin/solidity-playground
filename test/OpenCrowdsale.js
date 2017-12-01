const Token = artifacts.require("./token/ConfigurableERC20.sol");
const Crowdsale = artifacts.require("./OpenCrowdsale.sol");

contract('Token tests', function(accounts) {
	it("Token is deployed with correct values", async function() {
		const token = await Token.new(
			"108",
			"Token 108",
			0,
			400
		);
		assert.equal(await token.symbol(), "108", "Symbol name is incorrect");
		assert.equal(await token.name(), "Token 108", "Name is incorrect");
		assert.equal((await token.totalSupply.call()).toString(10), 400, "Total supply is incorrect");
	});
	it("Is impossible to deploy totalSupply 0", async function() {
		try {
			await Token.new(
				"108",
				"Token 108",
				0,
				0
			);
			fail('Deployed totalSupply 0');
		}
		catch(e) {
			// Only contract validation fail is expected
			if(e.message.indexOf('invalid opcode') < 0 &&
				e.message.indexOf('VM Exception while processing transaction: revert') < 0 /* testrpc 6.0.3 */) {
				throw e;
			}
		}
	});
	it("Is possible to do correct transfer", async function() {
		const token = await Token.new(
			"108",
			"Token 108",
			0,
			400
		);
		assert.equal((await token.balanceOf.call(accounts[0])).toString(10), 400, 'Balance before is incorrect');
		assert.equal((await token.balanceOf.call(accounts[1])).toString(10), 0, 'Balance before is incorrect');
		await token.transfer(accounts[1], 150);
		assert.equal((await token.balanceOf.call(accounts[0])).toString(10), 250, 'Balance after is incorrect');
		assert.equal((await token.balanceOf.call(accounts[1])).toString(10), 150, 'Balance after is incorrect');
	});
	it("Is impossible to transfer more than have", async function() {
		const token = await Token.new(
			"108",
			"Token 108",
			0,
			400
		);
		try {
			await token.transfer(accounts[1], 500);
			fail('transferred more than have');
		}
		catch(e) {
			// Only contract validation fail is expected
			if(e.message.indexOf('invalid opcode') < 0 &&
				e.message.indexOf('VM Exception while processing transaction: revert') < 0 /* testrpc 6.0.3 */) {
				throw e;
			}
		}
	});
});
