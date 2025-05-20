// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import {Token} from "./Token.sol";
import "hardhat/console.sol";

contract TokenFactory {
    uint256 public constant DECIMALS = 10 ** 18;
    uint256 public constant TOTAL_SUPPLY = 1000000 * DECIMALS;
    uint256 public constant INITIAL_SUPPLY = (TOTAL_SUPPLY / 100) * 80;
    uint256 public constant INITIAL_PRICE = 0.01 ether;

    uint256 public constant FUNDING_GOAL = 24 ether;

    struct MemeToken {
        string name;
        string symbol;
        string description;
        string imageUrl;
        uint256 amountRaised;
        address tokenAddress;
        address creatorAddress;
        uint256 currentSupply;
    }

    address[] allMemeTokensAddresses;

    mapping(address => MemeToken) public memeTokens;
    error NotEnoughCoinCreationFee(uint256 required, uint256 provided);
    error TokenDoesNotExist(address tokenAddress);
    error FundingGoalMet(
        address tokenAddress,
        uint256 amountRaised,
        uint256 fundingGoal
    );
    error NotEnoughTokenSupply(uint256 supply);

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
            creatorAddress: msg.sender,
            currentSupply: INITIAL_SUPPLY
        });

        allMemeTokensAddresses.push(memeTokenAddress);

        memeTokens[memeTokenAddress] = newMemeToken;

        console.log("Meme token created at address: %s", memeTokenAddress);

        return memeTokenAddress;
    }

    function buyMemeToken(
        address tokenAddress,
        uint256 _purchaseAmount
    )
        public
        payable
        tokenExists(tokenAddress)
        goalNotMet(tokenAddress)
        enoughSupply(_purchaseAmount)
        returns (uint256)
    {
        Token tokenCtxt = Token(memeTokens[tokenAddress].tokenAddress);

        uint256 currentSupplyScaled = tokenCtxt.totalSupply() -
            INITIAL_SUPPLY /
            DECIMALS;

        uint256 cost = calculateCost(currentSupplyScaled, _purchaseAmount);

        console.log("cost", cost);

        return cost;
    }

    function calculateCost(
        uint256 currentSupply,
        uint256 tokensToBuy
    ) public pure returns (uint256) {
        uint256 K = 1;
        // Calculate the exponent parts scaled to avoid precision loss
        uint256 exponent1 = (K * (currentSupply + tokensToBuy)) / 10 ** 18;
        uint256 exponent2 = (K * currentSupply) / 10 ** 18;

        // Calculate e^(kx) using the exp function
        uint256 exp1 = exp(exponent1);
        uint256 exp2 = exp(exponent2);

        // Cost formula: (P0 / k) * (e^(k * (currentSupply + tokensToBuy)) - e^(k * currentSupply))
        // We use (P0 * 10^18) / k to keep the division safe from zero
        uint256 cost = (INITIAL_PRICE * 10 ** 18 * (exp1 - exp2)) / K; // Adjust for k scaling without dividing by zero
        return cost;
    }

    // Improved helper function to calculate e^x for larger x using a Taylor series approximation
    function exp(uint256 x) internal pure returns (uint256) {
        uint256 sum = 10 ** 18; // Start with 1 * 10^18 for precision
        uint256 term = 10 ** 18; // Initial term = 1 * 10^18
        uint256 xPower = x; // Initial power of x

        for (uint256 i = 1; i <= 20; i++) {
            // Increase iterations for better accuracy
            term = (term * xPower) / (i * 10 ** 18); // x^i / i!
            sum += term;

            // Prevent overflow and unnecessary calculations
            if (term < 1) break;
        }

        return sum;
    }

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

    modifier enoughSupply(uint256 amount) {
        Token tokenCt = Token(memeTokens[msg.sender].tokenAddress);
        uint256 currentSupply = tokenCt.totalSupply();

        uint256 availableSupply = TOTAL_SUPPLY - currentSupply;

        uint256 scaledAvailableSupply = availableSupply / DECIMALS;
        uint scaledQuantity = amount * DECIMALS;

        if (currentSupply <= amount) {
            revert NotEnoughTokenSupply(currentSupply);
        }
        _;
    }
    // ---------------------------------------------------------------------------------------------
}
