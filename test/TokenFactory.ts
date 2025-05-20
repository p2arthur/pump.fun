import { expect } from "chai";
import hre from "hardhat";
import { TokenFactory } from "../typechain-types";

const name = "MemeToken";
const symbol = "MEME";
const description =
  "This is a meme token created for testing purposes. It has no real value and is not intended for any financial transactions.";
const imageUrl = "https://example.com/image.png";

let tokenFactoryClient: TokenFactory;
let memeTokenAddress: ;

describe("TokenFacotry", function () {
  it("Should create the token successfully", async function () {
    tokenFactoryClient = await hre.ethers.deployContract("TokenFactory");

    const address = await tokenFactoryClient.createMemeToken(
      name,
      symbol,
      description,
      imageUrl,
      { value: hre.ethers.parseEther("0.01") }
    );

    console.log("Transaction Hash:", address);
  });
  it("Should buy the token successfully", async function () {
    const tokenFactoryClient = await hre.ethers.deployContract("TokenFactory");

    const txn = await tokenFactoryClient.getPurchaseCost([address(memeTokenAddress)]);
  });
});
