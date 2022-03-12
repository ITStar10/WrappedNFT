import chai, { expect } from "chai"
import chaiAsPromised from "chai-as-promised"
import { solidity } from "ethereum-waffle";
import hre, { ethers } from "hardhat";

import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { BigNumber } from "@ethersproject/bignumber"
import { FNft, WNft } from "../typechain";

chai.use(solidity);
chai.use(chaiAsPromised);

describe("Augmented NFT", function () {
  let fNFT: FNft;
  let wNFT: WNft;

  let accountList: SignerWithAddress[];

  this.beforeAll(async () => {
    await hre.network.provider.send("hardhat_reset");
    accountList = await ethers.getSigners();

    const fnftFactory = await ethers.getContractFactory("FNft");
    fNFT = await fnftFactory.deploy();

    const wnftFactory = await ethers.getContractFactory("WNft");
    wNFT = await wnftFactory.deploy(fNFT.address);
  });

  it("Transfer In/Out", async () => {
    const testAccount = accountList[1];

    // console.log(await testAccount.getBalance());
    expect(await fNFT.balanceOf(testAccount.address, 0)).to.be.eq(0);

    await fNFT
      .connect(testAccount)
      .mint("a", 8, { value: ethers.utils.parseEther("0.05") });

    expect(await fNFT.balanceOf(testAccount.address, 0)).to.be.eq(1);

    // Transfer FNFT to wNFT
    expect(await wNFT.balanceOf(testAccount.address, 0)).to.be.eq(0);

    await fNFT
      .connect(testAccount)
      .safeTransferFrom(testAccount.address, wNFT.address, 0, 1, []);
    // Auto minted in WNFT
    expect(await wNFT.balanceOf(testAccount.address, 0)).to.be.eq(1);

    const buyer = accountList[2];
    // Transfer wNFT to buyer
    await wNFT
      .connect(testAccount)
      .safeTransferFrom(testAccount.address, buyer.address, 0, 1, []);

    expect(await wNFT.balanceOf(buyer.address, 0)).to.be.eq(1);
    // Restor FNFT
    expect(await fNFT.balanceOf(buyer.address, 0)).to.be.eq(0);
    await wNFT
      .connect(buyer)
      .safeTransferFrom(buyer.address, wNFT.address, 0, 1, []);

    expect(await fNFT.balanceOf(buyer.address, 0)).to.be.eq(1);
  });
});
