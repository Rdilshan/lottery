// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract TokenForwarder {
    event Paid(address indexed from, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);

    // Allow contract to receive native tokens (POL/MATIC/ETH)
    receive() external payable {}
    fallback() external payable {}

    // Function to deposit POL into contract
    function pay() external payable {
        require(msg.value > 0, "Must send some POL");
        emit Paid(msg.sender, msg.value);
    }

    // User requests an amount to withdraw to their wallet
    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        require(address(this).balance >= amount, "Not enough balance in contract");

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdraw failed");

        emit Withdrawn(msg.sender, amount);
    }
}
