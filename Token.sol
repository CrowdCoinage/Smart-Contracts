pragma solidity ^0.4.16;


import "./SafeMathLib.sol";
import "./Destructible.sol";
import "./ERC20.sol";


contract Token is ERC20, Destructible {
    using SafeMath for uint256;

    string  public name = "CrowdCoinage";       // Token name, for display purposes
    string  public symbol = "CCOS";             // Token symbol, for display purposes
    uint8   public decimals = 18;               // Decimal places
    uint256 public totalSupply = 478571428;     // Total number of tokens

    uint    public preStartSale;    // Unix date when the presale starts
    uint    public endSale;         // Unix date when the sale ends

    mapping (address => uint256) public balanceOf;              // Token balances
    mapping (address => mapping (address => uint256)) allowed;  // Allowances


    event Transfer(address indexed from, address indexed to, uint256 value);        // Transfer event
    event Approval(address indexed _owner, address indexed _spender, uint _value);  // Approval event
    event Burn(address indexed from, uint256 value);                                // Token burn event
    event Mint(address indexed to, uint256 amount);                                 // Mint event

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function Token(uint _preStartSale, uint _endSale) public {
        updateDates(_preStartSale, _endSale);   // Assign crowdsale dates
        balanceOf[msg.sender] = totalSupply;    // Give the creator all initial tokens
    }

    modifier afterDatesAndDelay() {
        if (!isOwner(msg.sender)) {
            // Halts all transactions for crowdsale period and for 6 months after that
            require((now >= preStartSale && now <= endSale) || now >= endSale + 180 days);
        }
        _;
    }

    function totalSupply() public constant returns (uint256) {
        return totalSupply;
    }

    function balanceOf(address _owner) public constant returns (uint256) {
        return balanceOf[_owner];
    }

    function updateDates(uint _preStartSale, uint _endSale) public onlyOwner {
        preStartSale = _preStartSale;
        endSale = _endSale;
    }

    /**
     * Minting function
     */
    function mint(address _to, uint256 _value) public onlyOwner returns (bool) {
        require(_to != 0x0);                                // Prevent transfer to 0x0 address
        require(now >= preStartSale && now <= endSale);     // Prevent minting during crowdsale
        require(balanceOf[_to] + _value > balanceOf[_to]);  // Check for overflows

        totalSupply += _value;      // Increment the total supply of tokens count
        balanceOf[_to] += _value;   // Update reciever balance
        Mint(_to, _value);          // Broadcast the event

        return true;
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        return _transfer(msg.sender, _to, _value);
    }

    function allowance(address _owner, address _spender) public whenNotPaused constant returns (uint256) {
        return allowed[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused afterDatesAndDelay returns (bool) {
        var _allowance = allowed[_from][msg.sender];

        // Will not have to test for allowance being bigger as _allowance.sub(_value) does it for us

        if (_transfer(_from, _to, _value)) {
            allowed[_from][msg.sender] = _allowance.sub(_value);  // Remove allowance
            return true;
        }
        revert();
    }

    function approve(address _spender, uint256 _amount) public whenNotPaused returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    /**
     * Internal transfer, can only be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal afterDatesAndDelay returns (bool success) {
        require(_value > 0);                                        // Require amount to be bigger than 0
        require(_to != 0x0);                                        // Prevent transfer to 0x0 address
        require(balanceOf[_from] >= _value);                        // Check if the sender has enough tokens
        assert(balanceOf[_to] + _value > balanceOf[_to]);           // Check for overflows
        uint previousBalances = balanceOf[_from] + balanceOf[_to];  // Save this for the assertion check
        balanceOf[_from] = balanceOf[_from].sub(_value);            // Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add(_value);                // Add the same to the recipient
        Transfer(_from, _to, _value);                               // Fire the event

        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
        return true;
    }
}
