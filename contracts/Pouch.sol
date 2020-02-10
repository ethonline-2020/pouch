pragma solidity >=0.5.0;

interface MintInterface {
    function mint(uint256) external returns (uint256);
    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
}

contract TokenInterface {
    mapping(address => uint256) public nonces;
    function allowance(address, address) external view returns (uint256);
    function approve(address, uint256) external;
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function permit(
        address,
        address,
        uint256,
        uint256,
        bool,
        uint8,
        bytes32,
        bytes32
    ) external;
}

contract Pouch {
    uint256 public totalDaiDeposits;
    mapping(address => bool) registeredUser;
    mapping(address => uint256) balances;

    address daiAddress = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
    address cDaiAddress = 0xe7bc397DBd069fC7d0109C0636d06888bb50668c;

    MintInterface cDai = MintInterface(cDaiAddress);
    TokenInterface dai = TokenInterface(daiAddress);

    function checkDaiAllowance() external view returns (uint256) {
        return dai.allowance(msg.sender, address(this));
    }

    function userBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    function deposit(address sender, uint256 amount) external {
        dai.transferFrom(sender, address(this), amount);
        totalDaiDeposits += amount;
        dai.approve(cDaiAddress, amount);
        cDai.mint(amount);
        balances[sender] += amount;
        registeredUser[sender] = true;
    }

    function transact(address recipient, uint256 amount) external {
        require(registeredUser[msg.sender] == true, "Sender not registered");
        require(amount <= balances[msg.sender], "Insufficient Funds");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
    }

    function withdraw(uint256 amount) external {
        require(amount <= balances[msg.sender], "Insufficient Funds");
        cDai.redeemUnderlying(amount);
        dai.transfer(msg.sender, amount);
        balances[msg.sender] -= amount;
    }

    function contractBalance() external view returns (uint256) {
        return cDai.balanceOf(address(this));
    }
}
