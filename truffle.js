const HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
	networks: {
		development: {
			provider: new HDWalletProvider(
				"scan rice rival trend finger trash valve know swear snow dust neutral",
				"https://ropsten.infura.io/***key***"
			),
			network_id: "3", // Match only Ropsten
			gas: 2000000,
			gasPrice: 50000000000 // 50 GWei
		},
		testrpc: {
			host: "localhost",
			port: 8545,
			network_id: "*", // Match any network id
			gas: 2000000
		}
	}
};
