pragma solidity >=0.5.0;

// import "./interfaces/TokenInterface.sol";
import "./interfaces/cTokenInterface.sol";
import "./interfaces/EIP20Interface.sol";
import "./EIP712MetaTransaction.sol";

contract Pouch is EIP712MetaTransaction("Pouch", "1") {
    // uint256 public totalDaiDeposits;
    // mapping(address => bool) registeredUser;
    mapping(address => uint256) balances;
    address public admin;
    
    uint256 cDaiAllowedAmount = 350000000000000000000000000000000000000000000;
    address daiAddress = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
    address cDaiAddress = 0xe7bc397DBd069fC7d0109C0636d06888bb50668c;

    EIP20Interface daiToken = EIP20Interface(daiAddress);
    cTokenInterface cDai = cTokenInterface(cDaiAddress);

    constructor() public {
        admin = msg.sender;
        daiToken.approve(cDaiAddress, cDaiAllowedAmount);
    }

    modifier adminOnly() {
        require(msg.sender == admin, "Not authorized");
        _;
    }
    // ** Deposit DAI **
    function deposit(uint256 value) external {
        // Check if User's Dai Balance is more or equal to the value sent.
        uint256 userBalance = daiToken.balanceOf(msgSender());
        require(
            userBalance >= value,
            "User does not have the required DAI balance."
        );

        daiToken.transferFrom(msgSender(), address(this), value);
        balances[msgSender()] += value;
        totalSupply += value;
        emit Transfer(
            0x0000000000000000000000000000000000000000,
            msgSender(),
            value
        );

        // Check for Dai allowance given from this contract to Cdai Contract
        uint256 cDaiAllowance = daiToken.allowance(address(this), cDaiAddress);
        if (cDaiAllowance < value) {
            uint256 amount = value > cDaiAllowedAmount
                ? value
                : cDaiAllowedAmount;
            daiToken.approve(cDaiAddress, amount);
        }

        cDai.mint(value);
    }

    // ** Withdraw DAI**
    function withdraw(uint256 value) external {
        // Check if User's PCH balance is more or equal to the value sent.
        uint256 pouchBalance = balanceOf(msgSender());
        require(
            pouchBalance >= value,
            "User does not have the required PCH balance."
        );

        // Burn PCH
        transfer(0x0000000000000000000000000000000000000000, value);
        totalSupply -= value;

        // Redeem User's DAI from compound and transfer it to user.
        cDai.redeemUnderlying(value);
        daiToken.transfer(msgSender(), value);
    }

    function spitProfits() external adminOnly {
        uint256 adjustedTotalSupply = totalSupply.mul(100000000);
        uint256 ourContractBalance = cDai.balanceOf(address(this));
        uint256 cDaiExchangeRate = cDai.exchangeRateCurrent();
        uint256 cDaiExchangeRateDivided = cDaiExchangeRate.div(10000000000);

        uint256 currentPrice = adjustedTotalSupply.div(cDaiExchangeRateDivided);
        uint256 profit = ourContractBalance.sub(currentPrice);
        cDai.transfer(msg.sender, profit);

    }

    function myCurrentBalance() external view returns (uint256) {
        return cDai.balanceOf(address(this));
    }

    function getExchangeRate() external view returns (uint256) {
        return cDai.exchangeRateCurrent();
    }

    function checkProfits() external view returns (uint256) {
        uint256 adjustedTotalSupply = totalSupply.mul(100000000);
        uint256 ourContractBalance = cDai.balanceOf(address(this));
        uint256 cDaiExchangeRate = cDai.exchangeRateCurrent();
        uint256 cDaiExchangeRateDivided = cDaiExchangeRate.div(10000000000);

        uint256 currentPrice = adjustedTotalSupply.div(cDaiExchangeRateDivided);
        uint256 profit = ourContractBalance.sub(currentPrice);
        return profit;
    }
    // MintInterface cDai = MintInterface(cDaiAddress);
    // TokenInterface dai = TokenInterface(daiAddress);

    // function checkDaiAllowance() external view returns (uint256) {
    //     return dai.allowance(msg.sender, address(this));
    // }

    // function userBalance() external view returns (uint256) {
    //     return balances[msg.sender];
    // }

    // function deposit(address sender, uint256 amount) external {
    //     dai.transferFrom(sender, address(this), amount);
    //     totalDaiDeposits += amount;
    //     dai.approve(cDaiAddress, amount);
    //     cDai.mint(amount);
    //     balances[sender] += amount;
    //     registeredUser[sender] = true;
    // }

    // function transact(address recipient, uint256 amount) external {
    //     require(registeredUser[msg.sender] == true, "Sender not registered");
    //     require(amount <= balances[msg.sender], "Insufficient Funds");
    //     balances[msg.sender] -= amount;
    //     balances[recipient] += amount;
    // }

    // function withdraw(uint256 amount) external {
    //     require(amount <= balances[msg.sender], "Insufficient Funds");
    //     cDai.redeemUnderlying(amount);
    //     dai.transfer(msg.sender, amount);
    //     balances[msg.sender] -= amount;
    // }

    // function contractBalance() external view returns (uint256) {
    //     return cDai.balanceOf(address(this));
    // }
}
