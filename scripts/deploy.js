// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const { expect } = require("chai");

async function main() {
  const [deployer, addr1, addr2, addr3, addr4, ...addrs] =
    await hre.ethers.getSigners();

  const Token = await hre.ethers.getContractFactory("Token");
  initialSupply = hre.ethers.utils.parseEther("1000000");
  const token = await Token.deploy(initialSupply);

  console.log("TOKEN DEPLOYED TO:", token.address);

  const Staker = await hre.ethers.getContractFactory("Staker");
  const staker = await Staker.deploy(token.address, 100, 60 * 24);

  console.log("STAKER DEPLOYED TO:", staker.address);

  stakerSupply = hre.ethers.utils.parseEther("500000");
  token.connect(deployer).transfer(staker.address, stakerSupply);

  stakerBalance = await token.balanceOf(staker.address);
  console.log(
    "STAKER BALANCE: ",
    hre.ethers.utils.formatEther(stakerBalance.toString())
  );

  await staker
    .connect(addr1)
    .stake({ value: hre.ethers.utils.parseEther("1") });

  await staker
    .connect(addr2)
    .stake({ value: hre.ethers.utils.parseEther("10") });

  await staker
    .connect(addr3)
    .stake({ value: hre.ethers.utils.parseEther("100") });

  // too much ETH
  await expect(
    staker.connect(addr4).stake({ value: hre.ethers.utils.parseEther("1000") })
  ).to.be.revertedWith("too much ETH. Max 100 ETH");

  // too little ETH
  await expect(staker.connect(addr5).stake({ value: 1000 })).to.be.revertedWith(
    "not enough ETH. Min 1 ETH"
  );

  // too little ETH
  await expect(
    staker.connect(addr1).stake({ value: hre.ethers.utils.parseEther("1") })
  ).to.be.revertedWith("You cannot stake right now!");

  console.log("Added all stakes with no errors");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
