// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const [deployer, addr1, addr2, ...addrs] = await hre.ethers.getSigners();

  const Staker = await hre.ethers.getContractFactory("Staker");
  const staker = await Staker.deploy();

  console.log("STAKER DEPLOYED TO:", staker.address);

  const Token = await hre.ethers.getContractFactory("Token");
  initialSupply = hre.ethers.utils.parseEther("1000000");
  const token = await Token.deploy(initialSupply);

  console.log("TOKEN DEPLOYED TO:", token.address);

  stakerSupply = hre.ethers.utils.parseEther("500000");
  token.connect(deployer).transfer(staker.address, stakerSupply);

  stakerBalance = await token.balanceOf(staker.address);
  console.log("STAKER BALANCE: ", hre.ethers.utils.formatEther(stakerBalance.toString()));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
