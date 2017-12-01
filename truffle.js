module.exports = {
	networks: {
		development: {
			host: "localhost",
			port: 8545,
			network_id: "*", // Match any network id
			gas: 2000000,
			gasPrice: 1000000000
		},
		testrpc: {
			host: "localhost",
			port: 8550,
			network_id: "*", // Match any network id
			gas: 2000000
		},
		coverage: {
			host: "localhost",
			network_id: "*",
			port: 8551,         // <-- If you change this, also set the port option in .solcover.js.
			gas: 0xfffffffffff, // <-- Use this high gas value
			gasPrice: 0x01      // <-- Use this low gas price
		}
	}
};
