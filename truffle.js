const HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
	networks: {
		development: {
			provider: new HDWalletProvider("***mnemonic***", "https://ropsten.infura.io/***key***"),
			network_id: "3", // Match any network id
			gas: 4000000,
			gasPrice: 20000000000 // 20 GWei
		},
		testrpc: {
			host: "localhost",
			port: 8545,
			network_id: "*", // Match any network id
			gas: 2000000
		}
	}
};
