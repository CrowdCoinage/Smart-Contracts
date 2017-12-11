pragma solidity ^0.4.16;


import "./Destructible.sol";


contract Relay is Destructible {
    address public currentVersion;

    function Relay(address _contractAddress) public {
        update(_contractAddress);
        owner = msg.sender;
    }

    function () public payable {
        if (!currentVersion.delegatecall(msg.data)) {
            revert();
        }
    }

    function update(address newAddress) public onlyOwner {
        currentVersion = newAddress;
    }
}