pragma solidity ^0.4.16;


import "./Pausable.sol";


contract Destructible is Pausable {
    function destroy() public onlyOwner {
        selfdestruct(getOwner());
    }
}