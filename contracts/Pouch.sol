pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

import "./interfaces/TokenInterface.sol";
import "./interfaces/cTokenInterface.sol";
import "./interfaces/PTokenInterface.sol";
import "./libraries/SafeMath.sol";
import "./PouchStorage.sol";

contract Pouch is PTokenInterface, PouchStorage {
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
        if (value >= 1e19) {
            uint256 profitInDai = checkProfits().mul(getExchangeRate());
            uint256 checkProfitInDai = profitInDai.div(1e18);
            if (checkProfitInDai >= 1e18) {
                uint256 myReward = _randomReward();
                cDai.redeemUnderlying(myReward);
                daiToken.transfer(msg.sender, myReward);
                emit Reward(address(this), holder, myReward);
                return true;
            }
        }
        return true;
    }

    /* For Testing Purposes Only*/

    function transactTest(
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
        if (value >= 1e18) {
            uint256 profitInDai = checkProfits().mul(getExchangeRate());
            uint256 checkProfitInDai = profitInDai.div(1e18);
            if (checkProfitInDai >= 1e10) {
                uint256 userRewarded = _randomReward();
                cDai.redeemUnderlying(userRewarded);
                daiToken.transfer(holder, userRewarded);
                emit Reward(address(this), holder, userRewarded);
                rewards[holder] += userRewarded;
                return true;
            }
        }
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

    function spitProfits() public returns (bool) {
        uint256 profit = checkProfits();
        cDai.transfer(msg.sender, profit);
        return true;
    }

    function checkProfits() public view returns (uint256) {
        uint256 adjustedTotalSupply = (getMySupply()).mul(1e8);
        uint256 ourContractBalance = cDai.balanceOf(admin);
        uint256 cDaiExchangeRateDivided = (cDai.exchangeRateStored()).div(1e10);

        uint256 currentPrice = adjustedTotalSupply.div(cDaiExchangeRateDivided);
        return ourContractBalance.sub(currentPrice);
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
            2;
        return randomnumber.mul(1e10);
    }

}
