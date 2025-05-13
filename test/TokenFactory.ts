import { expect } from "chai";
import hre from "hardhat";

const name = "MemeToken";
const symbol = "MEME";
const description =
  "This is a meme token created for testing purposes. It has no real value and is not intended for any financial transactions.";
const imageUrl = "https://example.com/image.png";

describe("TokenFacotry", function () {
  it("Should create the token successfully", async function () {
    const tokenFactoryClient = await hre.ethers.deployContract("TokenFactory");

    const txn = await tokenFactoryClient.createMemeToken(
      name,
      symbol,
      description,
      imageUrl,
      { value: hre.ethers.parseEther("0.01") }
    );
  });
});
