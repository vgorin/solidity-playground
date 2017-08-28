module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*", // Match any network id
      gas: 4000000
    },
    testrpc: {
      host: "localhost",
      port: 8546,
      network_id: "*", // Match any network id
      gas: 4000000
    }
  }
};
