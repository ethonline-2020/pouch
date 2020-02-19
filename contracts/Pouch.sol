pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

import "./interfaces/TokenInterface.sol";
import "./interfaces/cTokenInterface.sol";
import "./interfaces/PTokenInterface.sol";
import "./libraries/SafeMath.sol";

contract Pouch is PTokenInterface {
    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    address public admin;
    address cDaiAddress = 0xe7bc397DBd069fC7d0109C0636d06888bb50668c;
    cTokenInterface cDai = cTokenInterface(cDaiAddress);

    address daiAddress = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
    TokenInterface daiToken = TokenInterface(daiAddress);

    address public ImplementationAddress;
    bytes32 public DOMAIN_SEPARATOR;

    bytes32 public constant DEPOSIT_TYPEHASH = keccak256(
        "Deposit(address holder,uint256 value,uint256 nonce)"
    );
    bytes32 public constant WITHDRAW_TYPEHASH = keccak256(
        "Withdraw(address holder,uint256 value,uint256 nonce)"
    );
    bytes32 public constant TRANSACT_TYPEHASH = keccak256(
        "Transact(address holder,address to,uint256 value,uint256 nonce)"
    );
    mapping(address => uint256) public nonces;

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

    using SafeMath for uint256;

    function deposit(
        address holder,
        uint256 value,
        uint256 nonce,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public returns (bool) {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(DEPOSIT_TYPEHASH, holder, value, nonce))
            )
        );

        require(holder != address(0), "Pouch/invalid-address-0");
        require(holder == ecrecover(digest, v, r, s), "Pouch/invalid-permit");
        require(nonce == nonces[holder]++, "Pouch/invalid-nonce");

        // ** Check for sufficient Funds **
        uint256 userBalance = daiToken.balanceOf(holder);
        require(userBalance >= value, "Insufficient Funds");

        daiToken.transferFrom(holder, address(this), value); // **Transfer User's DAI**
        balances[holder] += value;
        totalSupply += value;
        emit Transfer(address(0), holder, value); // **Mint PCH tokens for the User**
        daiToken.approve(cDaiAddress, value);
        cDai.mint(value); // **Mint cDai  **
        return true;
    }

    // ** Withdraw DAI**
    function withdraw(
        address holder,
        uint256 value,
        uint256 nonce,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public returns (bool) {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(WITHDRAW_TYPEHASH, holder, value, nonce))
            )
        );

        require(holder != address(0), "Pouch/invalid-address-0");
        require(holder == ecrecover(digest, v, r, s), "Pouch/invalid-permit");
        require(value <= balances[holder], "Insufficient Funds");
        require(nonce == nonces[holder]++, "Pouch/invalid-nonce");

        // ** Burn Pouch Token **
        _transfer(holder, address(0), value);
        totalSupply -= value;

        // **  Redeem User's DAI from compound and transfer it to user.**
        cDai.redeemUnderlying(value);
        daiToken.transfer(holder, value);
        return true;
    }

    function transact(
        address holder,
        address to,
        uint256 value,
        uint256 nonce,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public returns (bool) {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(TRANSACT_TYPEHASH, holder, to, value, nonce)
                )
            )
        );

        require(holder != address(0), "Pouch/invalid-address-0");
        require(holder == ecrecover(digest, v, r, s), "Pouch/invalid-permit");
        require(value <= balances[holder], "Insufficient Funds");
        require(to != address(0));
        require(nonce == nonces[holder]++, "Pouch/invalid-nonce");

        // ** Transfer Funds **
        _transfer(holder, to, value);

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

    function getExchangeRate() public view returns (uint256) {
        return cDai.exchangeRateStored();
    }

    function getMySupply() public view returns (uint256) {
        TokenInterface pouch = TokenInterface(admin);
        return pouch.totalSupply();
    }

    function checkContractBalance() public view returns (uint256) {
        return cDai.balanceOf(admin);
    }
    // function getExchangeRate() view public returns (uint) {
    //     return cDai.exchangeRateCurrent();
    // }

    function spitProfits() public returns (bool) {
        uint256 profit = checkProfits();
        cDai.transfer(msg.sender, profit);
        return true;
    }

    function checkProfits() public view returns (uint256) {
        uint256 contractSupply = getMySupply();
        uint256 adjustedTotalSupply = contractSupply.mul(1e8);
        uint256 ourContractBalance = cDai.balanceOf(admin);
        uint256 cDaiExchangeRate = cDai.exchangeRateStored();
        uint256 cDaiExchangeRateDivided = cDaiExchangeRate.div(1e10);

        uint256 currentPrice = adjustedTotalSupply.div(cDaiExchangeRateDivided);
        uint256 profit = ourContractBalance.sub(currentPrice);
        return profit;
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
    function _randomReward() internal view returns (uint256) {
        uint256 randomnumber = uint256(
            keccak256(abi.encodePacked(now, msg.sender, block.number))
        ) %
            5;
        return randomnumber.mul(1e10);
    }

}
