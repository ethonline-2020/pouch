pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

import "./interfaces/TokenInterface.sol";
import "./interfaces/cTokenInterface.sol";
import "./interfaces/PTokenInterface.sol";
import "./interfaces/proxyInterface.sol";
import "./libraries/SafeMath.sol";

contract Pouch is proxyInterface {
    using SafeMath for uint256;

    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    address public ImplementationAddress;
    address public admin;
    bytes32 public DOMAIN_SEPARATOR;
    // bytes32 public constant PERMIT_TYPEHASH = keccak256(
    //     "Permit(address holder,address spender,uint256 nonce,uint256 expiry,bool isAllowed)"
    // );
    // mapping(address => uint256) public nonces;
    uint256 private constant MAX_UINT256 = uint256(-1);

    bytes32 public constant DEPOSIT_TYPEHASH = keccak256(
        "Deposit(address holder,uint256 value)"
    );
    bytes32 public constant WITHDRAW_TYPEHASH = keccak256(
        "Withdraw(address holder,uint256 value)"
    );
    bytes32 public constant TRANSACT_TYPEHASH = keccak256(
        "Transact(address _from,address _to,uint256 _value)"
    );

    // // // Required Interfaces
    address daiAddress = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
    address cDaiAddress = 0xe7bc397DBd069fC7d0109C0636d06888bb50668c;
    address pDaiAddress = 0xb5cea18Db04008a4D68444A298DBDD2D0E442E3D;

    TokenInterface daiToken = TokenInterface(daiAddress);
    cTokenInterface cDai = cTokenInterface(cDaiAddress);
    PTokenInterface pDaiToken = PTokenInterface(pDaiAddress);

    constructor(address tokenAddress) public {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256("Pouch"),
                keccak256("1"),
                42, // kovan chainId
                tokenAddress
            )
        );
        admin = tokenAddress;
    }

    // ** Internal Functions **

    function _mint(address _to, uint256 _value)
        internal
        returns (bool success)
    {
        balances[_to] += _value;
        totalSupply += _value;
        emit Transfer(address(0), _to, _value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value)
        internal
        returns (bool success)
    {
        require(balances[_from] >= _value);
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    // ** Deposit DAI **
    function deposit(
        address holder,
        uint256 value,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public returns (bool) {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(DEPOSIT_TYPEHASH, holder, value))
            )
        );

        require(holder != address(0), "Pouch/invalid-address-0");
        require(holder == ecrecover(digest, v, r, s), "Pouch/invalid-permit");

        // ** Check for sufficient Funds **
        uint256 userBalance = daiToken.balanceOf(holder);
        require(userBalance >= value, "Insufficient Funds");

        daiToken.transferFrom(holder, address(this), value); // **Transfer User's DAI**
        _mint(holder, value); // **Mint PCH tokens for the User**
        daiToken.approve(cDaiAddress, value);
        cDai.mint(value); // **Mint cDai  **
        return true;
    }

    // ** Withdraw DAI**
    function withdraw(
        address holder,
        uint256 value,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public returns (bool) {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(WITHDRAW_TYPEHASH, holder, value))
            )
        );

        require(holder != address(0), "Pouch/invalid-address-0");
        require(holder == ecrecover(digest, v, r, s), "Pouch/invalid-permit");
        require(value <= balances[holder], "Insufficient Funds");

        //          ** Burn Pouch Token **
        _transfer(holder, address(0), value);
        totalSupply -= value;

        //         **  Redeem User's DAI from compound and transfer it to user.**
        cDai.redeemUnderlying(value);
        daiToken.transfer(holder, value);
        return true;
    }

    //     function getExchangeRate() view public returns (uint) {
    //         return cDai.exchangeRateCurrent();
    //     }

    //   function _randomReward() internal view returns (uint) {
    //         uint randomnumber = uint(keccak256(abi.encodePacked(now, msg.sender,block.number))) % 5;
    //         return randomnumber.mul(1e10);
    //     }

    function transact(
        address _from,
        address _to,
        uint256 _value,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public returns (bool) {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(TRANSACT_TYPEHASH, _from, _to, _value))
            )
        );

        require(_from != address(0), "Pouch/invalid-address-0");
        require(_from == ecrecover(digest, v, r, s), "Pouch/invalid-permit");
        require(_value <= balances[_from], "Insufficient Funds");
        require(_to != address(0));

        // ** Transfer Funds **
        _transfer(_from, _to, _value);

        // ** Transfer Rewards,if Any. **
        // if (value >= 1e18){
        //     uint profitInDai =  _checkProfits().mul(getExchangeRate());
        //     uint checkProfitInDai = profitInDai.div(1e18);
        //     if(checkProfitInDai >= 1e11){
        //         uint myReward =  _randomReward();
        //         cDai.redeemUnderlying(myReward);
        //         daiToken.transfer(msg.sender, myReward);

        //     return true;
        //     }
        // }
        return true;
    }

    // function _spitProfits() public returns (bool){

    //     uint256 adjustedTotalSupply = totalSupply.mul(1e8);
    //     uint256 ourContractBalance = cDai.balanceOf(admin);
    //     uint256 cDaiExchangeRate = cDai.exchangeRateCurrent();
    //     uint256 cDaiExchangeRateDivided = cDaiExchangeRate.div(1e10);

    //     uint256 currentPrice = adjustedTotalSupply.div(cDaiExchangeRateDivided);
    //     uint256 profit = ourContractBalance.sub(currentPrice);
    //     cDai.transfer(msg.sender, profit);
    //     return true;
    // }

    // function _checkProfits() public returns (uint256) {
    //     uint256 adjustedTotalSupply = totalSupply.mul(1e8);
    //     uint256 ourContractBalance = cDai.balanceOf(admin);
    //     uint256 cDaiExchangeRate = cDai.exchangeRateCurrent();
    //     uint256 cDaiExchangeRateDivided = cDaiExchangeRate.div(1e10);

    //     uint256 currentPrice = adjustedTotalSupply.div(cDaiExchangeRateDivided);
    //     uint256 profit = ourContractBalance.sub(currentPrice);
    //     return 5;
    // }

}
