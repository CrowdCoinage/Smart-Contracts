pragma solidity ^0.4.16;


import "./Ownable.sol";


contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool _paused = false;   // Contract state

    /**
     * Constructor
     */
    function paused() public constant returns(bool) {
        return _paused;
    }

    /**
     * @dev modifier to allow actions only when the contract IS paused
     */
    modifier whenNotPaused() {
        require(!paused() || owner == msg.sender);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner {
        require(!_paused);
        _paused = true;
        Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner {
        require(_paused);
        _paused = false;
        Unpause();
    }
}
