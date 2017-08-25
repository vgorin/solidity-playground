module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*", // Match any network id
      gas: 800000
    },
    testrpc: {
      host: "localhost",
      port: 8546,
      network_id: "*", // Match any network id
      gas: 2000000
    }
  }
};
