// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract Lottery is Ownable {
    IERC20 public polToken;
    uint256 public ticketPrice;
    uint256 public lotteryDuration; 
    IERC20Metadata public Token;

    uint256 public currentLotteryId;
    uint256 public lastDrawTime;
address VALID_ERC20_TOKEN_ADDRESS = 0x742d35Cc6634C0532925a3b844Bc454e4438f44e;


    struct Ticket {
        address buyer;
        uint8[4] numbers;
    }

    mapping(uint256 => Ticket[]) public lotteryTickets;
    mapping(uint256 => uint8[4]) public winningNumbers;
    mapping(uint256 => bool) public isDrawn;

    constructor(address _polToken, uint256 _ticketPrice, uint256 _durationInDays)
        Ownable(msg.sender)  // ✅ Pass the owner (e.g., deployer address)
    {
        polToken = IERC20(_polToken);
        Token = IERC20Metadata(_polToken);
        ticketPrice = _ticketPrice;
        lotteryDuration = _durationInDays * 1 days;
        lastDrawTime = block.timestamp;
        currentLotteryId = 1;
    }

    function buyTicket(uint8[4] memory numbers) external {
        require(_areUnique(numbers), "Numbers must be unique");
        require(polToken.transferFrom(msg.sender, address(this), ticketPrice), "Payment failed");

        lotteryTickets[currentLotteryId].push(Ticket({
            buyer: msg.sender,
            numbers: numbers
        }));
    }

    function drawWinningNumbers(uint8[4] memory numbers) external onlyOwner {
        require(!isDrawn[currentLotteryId], "Already drawn");
        require(block.timestamp >= lastDrawTime + lotteryDuration, "Too early");

        require(_areUnique(numbers), "Winning numbers must be unique");

        winningNumbers[currentLotteryId] = numbers;
        isDrawn[currentLotteryId] = true;

        lastDrawTime = block.timestamp;
        currentLotteryId += 1;
    }

    function claimReward(uint256 lotteryId) external {
        require(isDrawn[lotteryId], "Winning numbers not drawn");

        uint8[4] memory winNums = winningNumbers[lotteryId];
        Ticket[] memory tickets = lotteryTickets[lotteryId];

        for (uint256 i = 0; i < tickets.length; i++) {
            if (tickets[i].buyer == msg.sender && _matchNumbers(tickets[i].numbers, winNums)) {
                // Reward logic here. Example: send back double
                require(polToken.transfer(msg.sender, ticketPrice * 10), "Reward transfer failed");
                break;
            }
        }
    }

    function _areUnique(uint8[4] memory nums) internal pure returns (bool) {
        for (uint8 i = 0; i < 4; i++) {
            for (uint8 j = i + 1; j < 4; j++) {
                if (nums[i] == nums[j]) return false;
            }
        }
        return true;
    }

    function _matchNumbers(uint8[4] memory a, uint8[4] memory b) internal pure returns (bool) {
        for (uint8 i = 0; i < 4; i++) {
            bool found = false;
            for (uint8 j = 0; j < 4; j++) {
                if (a[i] == b[j]) {
                    found = true;
                    break;
                }
            }
            if (!found) return false;
        }
        return true;
    }

function getPolTokenName() external view returns (string memory) {
    return IERC20Metadata(VALID_ERC20_TOKEN_ADDRESS).name();
}

}
