// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract TokenForwarder {
    address public constant RECEIVER = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    event PaymentReceived(address indexed from, uint256 amount);
    event Forwarded(address indexed to, uint256 amount);

    function payAndForward() external payable {
        require(msg.value > 0, "Send some POL");

        (bool success, ) = payable(RECEIVER).call{value: msg.value}("");
        require(success, "Forwarding failed");

        emit PaymentReceived(msg.sender, msg.value);
        emit Forwarded(RECEIVER, msg.value);
    }
}
