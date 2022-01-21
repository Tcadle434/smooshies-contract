const { utils } = require("ethers");

async function main() {
    const baseTokenURI = "https://gateway.pinata.cloud/ipfs/QmSeY8nvTQxT1wyfD5fZvEThfDnQwvmrQGAg4yt8UWirrf/";

    // Get owner/deployer's wallet address
    const [owner] = await hre.ethers.getSigners();

    // Get contract that we want to deploy
    const contractFactory = await hre.ethers.getContractFactory("Smooshies");

    // Deploy contract with the correct constructor arguments
    const contract = await contractFactory.deploy("Smooshies", "SMOOSHIE", baseTokenURI);

    // Wait for this transaction to be mined
    await contract.deployed();

    // Get contract address
    console.log("Contract deployed to:", contract.address);

    // Reserve NFTs
    let txn = await contract.reserve(4);
    await txn.wait();
    console.log("4 NFTs have been reserved");

    // Mint 3 NFTs by sending 0.03 ether
    // txn = await contract.mint(1, { value: utils.parseEther('0.1') });
    // await txn.wait()

    // Get all token IDs of the owner
    // let tokens = await contract.tokensOfOwner(owner.address)
    // console.log("Owner has tokens: ", tokens);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });