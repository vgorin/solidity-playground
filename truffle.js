module.exports = {
	networks: {
		ropsten: {
			host: "localhost",
			port: 8543,
			network_id: "*", // Match any network id
			gas: 2000000,
			gasPrice: 1000000000
		},
		rinkeby: {
			host: "localhost",
			port: 8544,
			network_id: "*", // Match any network id
			gas: 2000000,
			gasPrice: 1000000000
		},
		testrpc: {
			host: "localhost",
			port: 8546,
			network_id: "*", // Match any network id
			gas: 2000000
		}
	}
};
