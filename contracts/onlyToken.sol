// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract NativePOLBank {
    event Deposited(address indexed from, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);

    // Allow contract to receive native POL (like MATIC)
    receive() external payable {
        emit Deposited(msg.sender, msg.value);
    }

    // Fallback in case someone sends with data
    fallback() external payable {
        emit Deposited(msg.sender, msg.value);
    }

    // Function to withdraw the full contract balance to caller
    function withdrawAll() external {
        uint256 balance = address(this).balance;
        require(balance > 0, "No POL in contract");

        (bool success, ) = payable(msg.sender).call{value: balance}("");
        require(success, "Withdraw failed");

        emit Withdrawn(msg.sender, balance);
    }

    // Optional: show contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
