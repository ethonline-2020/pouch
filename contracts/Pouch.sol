pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

import "./interfaces/TokenInterface.sol";
import "./interfaces/cTokenInterface.sol";
import "./interfaces/PTokenInterface.sol";
// import "./interfaces/EIP20Interface.sol";
// import "./EIP712MetaTransaction.sol";

contract Pouch {
    /*is EIP712MetaTransaction("Pouch", "1")*/
    // uint256 public totalDaiDeposits;
    // mapping(address => bool) registeredUser;
    mapping(address => uint256) balances;
    address public admin;
    bytes32 public DOMAIN_SEPARATOR;
    struct Deposit {
        address holder;
        uint256 value;
    }
    bytes32 public constant DEPOSIT_TYPEHASH = keccak256(
        "Deposit(address holder,uint256 value)"
    );

    uint256 cDaiAllowedAmount = uint256(-1);
    address daiAddress = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
    address cDaiAddress = 0xe7bc397DBd069fC7d0109C0636d06888bb50668c;
    address pDaiAddress = 0xb5cea18Db04008a4D68444A298DBDD2D0E442E3D;

    TokenInterface daiToken = TokenInterface(daiAddress);
    cTokenInterface cDai = cTokenInterface(cDaiAddress);
    PTokenInterface pDaiToken = PTokenInterface(pDaiAddress);

    constructor() public {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256("Pouch"),
                keccak256("1"),
                42, // kovan chainId
                address(this)
            )
        );
        admin = msg.sender;
        // daiToken.approve(cDaiAddress, cDaiAllowedAmount);
    }

    modifier adminOnly() {
        require(msg.sender == admin, "Not authorized");
        _;
    }
    // ** Deposit DAI **
    function deposit(Deposit memory dep, bytes32 r, bytes32 s, uint8 v) public {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(DEPOSIT_TYPEHASH, dep.holder, dep.value))
            )
        );

        require(dep.holder != address(0), "Pouch/invalid-address-0");
        require(
            dep.holder == ecrecover(digest, v, r, s),
            "Pouch/invalid-permit"
        );
        // Check if User's Dai Balance is more or equal to the value sent.
        // uint256 userBalance = daiToken.balanceOf(dep.holder);
        // require(
        //     userBalance >= dep.value,
        //     "User does not have the required DAI balance."
        // );

        daiToken.transferFrom(dep.holder, address(this), dep.value);
        balances[dep.holder] += dep.value;

        // emit pDaiToken.Transfer(
        //     0x0000000000000000000000000000000000000000,
        //     holder,
        //     value
        // );

        // Check for Dai allowance given from this contract to Cdai Contract
        uint256 cDaiAllowance = daiToken.allowance(address(this), cDaiAddress);
        if (cDaiAllowance < dep.value) {
            uint256 amount = dep.value > cDaiAllowedAmount
                ? dep.value
                : cDaiAllowedAmount;
            daiToken.approve(cDaiAddress, amount);
        }

        cDai.mint(dep.value);
    }

    // // ** Withdraw DAI**
    // function withdraw(uint256 value) external {
    //     // Check if User's PCH balance is more or equal to the value sent.
    //     uint256 pouchBalance = pDaiToken.balanceOf(msgSender());
    //     require(
    //         pouchBalance >= value,
    //         "User does not have the required PCH balance."
    //     );

    //     // Burn PCH
    //     pDaiToken.transfer(0x0000000000000000000000000000000000000000, value);
    //     totalSupply -= value;

    //     // Redeem User's DAI from compound and transfer it to user.
    //     cDai.redeemUnderlying(value);
    //     daiToken.transfer(msgSender(), value);
    // }

    // function spitProfits() external adminOnly {
    //     uint256 adjustedTotalSupply = totalSupply.mul(100000000);
    //     uint256 ourContractBalance = cDai.balanceOf(address(this));
    //     uint256 cDaiExchangeRate = cDai.exchangeRateCurrent();
    //     uint256 cDaiExchangeRateDivided = cDaiExchangeRate.div(10000000000);

    //     uint256 currentPrice = adjustedTotalSupply.div(cDaiExchangeRateDivided);
    //     uint256 profit = ourContractBalance.sub(currentPrice);
    //     cDai.transfer(msg.sender, profit);

    // }

    // function myCurrentBalance() external view returns (uint256) {
    //     return cDai.balanceOf(address(this));
    // }

    // function getExchangeRate() external view returns (uint256) {
    //     return cDai.exchangeRateCurrent();
    // }

    // function checkProfits() external view returns (uint256) {
    //     uint256 adjustedTotalSupply = totalSupply.mul(100000000);
    //     uint256 ourContractBalance = cDai.balanceOf(address(this));
    //     uint256 cDaiExchangeRate = cDai.exchangeRateCurrent();
    //     uint256 cDaiExchangeRateDivided = cDaiExchangeRate.div(10000000000);

    //     uint256 currentPrice = adjustedTotalSupply.div(cDaiExchangeRateDivided);
    //     uint256 profit = ourContractBalance.sub(currentPrice);
    //     return profit;
    // }
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
