pragma solidity ^0.4.25;

interface ITRC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function transfer(address to, uint value) external returns (bool);

    function approve(address spender, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IApproveAndCallFallback {
    // _from: token owner
    // _value:
    // _token: token addr
    function receiveApproval(address _from, uint _value, address _token, bytes _data) external;
}

contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() external {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
}

contract TokenExchange is Ownable {
    using SafeMath for uint;
    
    mapping(address => uint) _amount;
    
    uint public TotalAmount;
    uint public UserMaxAmount;
    uint public Price;
    uint public RemainExchangeAmount;
    
    address public MyToken;
    uint public MyTokenDecimal;
    uint public USDTDecimal; 
    
    uint public StartTime;
    uint public EndTime;
    
    function exchangeAmount(address addr) external view returns (uint) {
        return _amount[addr];
    }
    
    function setExchange(address myToken, uint decimals, uint totalAmount, uint userMaxAmount, uint price) external onlyOwner {
        MyToken = myToken;
        MyTokenDecimal = 10 ** decimals;
                
        TotalAmount = totalAmount * MyTokenDecimal;
        UserMaxAmount = userMaxAmount * MyTokenDecimal;
        RemainExchangeAmount = TotalAmount;
        Price = price;
        
        USDTDecimal = 10 ** 6;
    }
    
    function start(uint startTime, uint dayCunt) external onlyOwner {
        if (startTime > block.timestamp) {
            StartTime = startTime;
        } else {
            StartTime = block.timestamp;
        }
        EndTime = StartTime + (1 days * dayCunt);
    }
    
    modifier onlyBegin {
        require(StartTime > 0 && block.timestamp >= StartTime && EndTime >= block.timestamp);
        _;
    }
    
    function exchange() external payable onlyBegin {
        require(_amount[msg.sender] < UserMaxAmount && RemainExchangeAmount > 0);
        uint amount = msg.value * MyTokenDecimal / Price / USDTDecimal;
        
        uint income = msg.value;
        uint revertVal = 0;
        if (_amount[msg.sender].add(amount) > UserMaxAmount) {
            amount = UserMaxAmount.sub(_amount[msg.sender]);
            if (amount > RemainExchangeAmount) {
                amount = RemainExchangeAmount;
            }
            income = amount * Price * USDTDecimal / MyTokenDecimal;
            revertVal = msg.value.sub(income);
        }
        
        RemainExchangeAmount = RemainExchangeAmount.sub(amount);
        
        owner.transfer(income);
        if (revertVal > 0) {
            msg.sender.transfer(revertVal);
        }
        _amount[msg.sender] = _amount[msg.sender].add(amount);
        ITRC20(MyToken).transferFrom(owner, msg.sender, amount);
    }
}