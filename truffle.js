const HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
	networks: {
		development: {
			provider: new HDWalletProvider(
				"***",
				"https://ropsten.infura.io/***"
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
