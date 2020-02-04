pragma solidity >=0.5.0;

interface MintInterface {
    function mint(uint256) external returns (uint256);
    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
}

interface TokenInterface {
    function allowance(address, address) external view returns (uint256);
    function approve(address, uint256) external;
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
}

contract Boundless {
    uint256 public totalDaiDeposits;
    mapping(address => bool) registeredUser;
    mapping(address => uint256) balances;
    address daiAddress = 0xB5E5D0F8C0cbA267CD3D7035d6AdC8eBA7Df7Cdd;
    address cDaiAddress = 0x2B536482a01E620eE111747F8334B395a42A555E;

    MintInterface cDai = MintInterface(cDaiAddress);
    TokenInterface dai = TokenInterface(daiAddress);

    function checkDaiAllowance() external view returns (uint256) {
        return dai.allowance(msg.sender, address(this));
    }

    function userBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    function deposit(uint256 amount) external {
        dai.transferFrom(msg.sender, address(this), amount);
        totalDaiDeposits += amount;
        dai.approve(cDaiAddress, amount);
        cDai.mint(amount);
        balances[msg.sender] += amount;
        registeredUser[msg.sender] = true;
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
