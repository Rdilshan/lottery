// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Lottery {
    address public constant WMATIC_ADDRESS = 0x0000000000000000000000000000000000001010;
    uint256 public ticketPrice = 1 ether; // 1 WMATIC (18 decimals)

    struct Ticket {
        address buyer;
        uint8[4] numbers;
    }

    Ticket[] public tickets;
    mapping(address => uint256[]) public userTickets; // track ticket indices by user

    event TicketPurchased(address indexed buyer, uint8[4] numbers);

    /**
     * Buy ticket - generates random 4 unique numbers
     */
    function buyTicket() external {
        // Transfer WMATIC
        require(
            IERC20(WMATIC_ADDRESS).transferFrom(msg.sender, address(this), ticketPrice),
            "WMATIC transfer failed"
        );

        uint8[4] memory numbers = generateUniqueNumbers(msg.sender, tickets.length);

        tickets.push(Ticket({
            buyer: msg.sender,
            numbers: numbers
        }));

        userTickets[msg.sender].push(tickets.length - 1);

        emit TicketPurchased(msg.sender, numbers);
    }

    /**
     * Generate 4 unique uint8 numbers (0-255) using pseudo-randomness
     */
    function generateUniqueNumbers(address user, uint256 nonce) internal view returns (uint8[4] memory) {
        uint8[4] memory result;
        uint8 count = 0;

        while (count < 4) {
            uint8 num = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, user, nonce, count))) % 100);

            bool exists = false;
            for (uint8 i = 0; i < count; i++) {
                if (result[i] == num) {
                    exists = true;
                    break;
                }
            }

            if (!exists) {
                result[count] = num;
                count++;
            }
        }

        return result;
    }

    /**
     * Get number of tickets a user bought
     */
    function getUserTicketCount(address user) external view returns (uint256) {
        return userTickets[user].length;
    }

    /**
     * Get specific ticket numbers of user
     */
    function getUserTicket(address user, uint256 index) external view returns (uint8[4] memory) {
        require(index < userTickets[user].length, "Invalid ticket index");
        return tickets[userTickets[user][index]].numbers;
    }
}
