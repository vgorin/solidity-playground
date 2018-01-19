const acc = [
	"0x03cdA1F3DEeaE2de4C73cfC4B93d3A50D0419C24",
	"0x25fcb8f929bf278669d575ba1a5ad1893e341069",
	"0x8f8488f9ce6f830e750bef6605137651b84f1835",
	"0x46c3fbed2c66ba8d7af7e2fc72d535798400d3f5"
];

module.exports = async function(deployer, network, accounts) {
	const Transfers = artifacts.require("./lib/Transfers");
	const Accumulator = artifacts.require("./SharedAccumulator");
	const Transfer = artifacts.require("./SharedTransfer");
	await deployer.deploy(Transfers);
	await deployer.link(Transfers, Accumulator);
	await deployer.link(Transfers, Transfer);

	await deployer.deploy(
		Accumulator,
		[
			acc[1],
			acc[2],
			acc[3]
		],
		[
			6, 2, 1, // shares under 0.01 ETH
			1, 6, 2, // shares between 0.01 and 0.02 ETH
			2, 1, 6  // shares over 0.02 ETH
		],
		[
			10000000000000000, // 0.01 ETH
			20000000000000000, // 0.02 ETH
			0
		]
	);
	const accumulator = Accumulator.address;

	await deployer.deploy(
		Transfer,
		[
			acc[1],
			acc[2],
			acc[3]
		],
		[
			6, 2, 1,
			1, 6, 2,
			2, 1, 6
		],
		[
			10000000000000000, // 0.01 ETH
			20000000000000000, // 0.02 ETH
			0
		]
	);
	const transfer = Accumulator.address;

	console.log("accumulator: " + accumulator);
	console.log("transfer: " + transfer);
};
