// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import {Token} from "./Token.sol";
import "hardhat/console.sol";

contract TokenFactory {
    uint256 public constant INITIAL_SUPPLY = 1000 * 10e18;
    uint256 public constant FUNDING_GOAL = 24 ether;

    struct MemeToken {
        string name;
        string symbol;
        string description;
        string imageUrl;
        uint256 amountRaised;
        address tokenAddress;
        address creatorAddress;
    }

    mapping(address => MemeToken) public memeTokens;
    error NotEnoughCoinCreationFee(uint256 required, uint256 provided);
    error TokenDoesNotExist(address tokenAddress);
    error FundingGoalMet(
        address tokenAddress,
        uint256 amountRaised,
        uint256 fundingGoal
    );

    // Create a memecoin
    function createMemeToken(
        string memory name,
        string memory symbol,
        string memory description,
        string memory imageUrl
    ) public payable payedEnoughCoinCreationFee returns (address) {
        Token token = new Token(name, symbol, INITIAL_SUPPLY);

        address memeTokenAddress = address(token);

        MemeToken memory newMemeToken = MemeToken({
            name: name,
            symbol: symbol,
            description: description,
            imageUrl: imageUrl,
            amountRaised: 0,
            tokenAddress: memeTokenAddress,
            creatorAddress: msg.sender
        });

        memeTokens[memeTokenAddress] = newMemeToken;

        console.log("Meme token created at address: %s", memeTokenAddress);

        return memeTokenAddress;
    }

    function buyMemeToken(
        address tokenAddress,
        uint256 purchaseQuantity
    )
        public
        payable
        tokenExists(tokenAddress)
        goalNotMet(tokenAddress)
        returns (uint256)
    {}

    // modfiers -----------------------------------------------------------------------------------
    modifier payedEnoughCoinCreationFee() {
        if (msg.value < 0.01 ether) {
            revert NotEnoughCoinCreationFee(msg.value, 0.01 ether);
        }
        _;
    }

    modifier tokenExists(address tokenAddress) {
        if (memeTokens[tokenAddress].tokenAddress != address(0)) {
            revert TokenDoesNotExist(tokenAddress);
        }
        _;
    }

    modifier goalNotMet(address tokenAddress) {
        MemeToken memory token = memeTokens[tokenAddress];

        uint256 amountRaised = token.amountRaised;

        if (amountRaised + msg.value > FUNDING_GOAL) {
            revert FundingGoalMet(tokenAddress, amountRaised, FUNDING_GOAL);
        }
        _;
    }
    // ---------------------------------------------------------------------------------------------
}
