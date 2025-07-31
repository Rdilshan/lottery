// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LotteryTicket {
    address public owner;

    event TicketPurchased(address indexed buyer, uint256 ticketId, uint256 amount);
    event TokensTransferred(address indexed to, uint256 amount);

    uint256 public ticketCount;
    uint256 public ticketPrice = 1 ether;

    struct Ticket {
        address owner;
        uint256 ticketId;
        uint256 timestamp; // time the ticket was bought
    }

    mapping(uint256 => Ticket) public tickets;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function buyTicket() external payable {
        require(msg.value == ticketPrice, "Send exactly 1 POL");

        tickets[ticketCount] = Ticket({
            owner: msg.sender,
            ticketId: ticketCount,
            timestamp: block.timestamp
        });

        emit TicketPurchased(msg.sender, ticketCount, msg.value);

        ticketCount++;
    }

    function transferPOL(address payable to, uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient contract balance");

        (bool sent, ) = to.call{value: amount}("");
        require(sent, "Transfer failed");

        emit TokensTransferred(to, amount);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
