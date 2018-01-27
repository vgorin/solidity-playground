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
			gasPrice: 150000000000 // 150 GWei
		},
		test: {
			host: "localhost",
			port: 8666,
			network_id: "*", // Match any network id
			gas: 2000000,
			gasPrice: 1
		},
		coverage: {
			host: "localhost",
			network_id: "*",
			port: 8555,         // <-- If you change this, also set the port option in .solcover.js.
			gas: 0xfffffffffff, // <-- Use this high gas value
			gasPrice: 0x01      // <-- Use this low gas price
		}
	}
};
