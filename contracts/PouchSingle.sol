pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

import "./interfaces/TokenInterface.sol";
import "./interfaces/cTokenInterface.sol";
import "./interfaces/PTokenInterface.sol";

contract PouchToken is PTokenInterface {
    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    // bytes32 public DOMAIN_SEPARATOR;
    // address public admin;
    // address cDaiAddress = 0xe7bc397DBd069fC7d0109C0636d06888bb50668c;
    // cTokenInterface cDai = cTokenInterface(cDaiAddress);
    // address daiAddress = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
    // TokenInterface daiToken = TokenInterface(daiAddress);
    // bytes32 public constant DEPOSIT_TYPEHASH = keccak256(
    //     "Deposit(address holder,uint256 value)"
    // );

    // mapping(address => uint256) public nonces;
    // bytes32 public constant PERMIT_TYPEHASH = keccak256(
    //     "Permit(address holder,address spender,uint256 nonce,uint256 expiry,bool isAllowed)"
    // );
    // address public ImplementationAddress;
    uint256 private constant MAX_UINT256 = uint256(-1);

    // --- ERC20 Data ---
    string public constant name = "Pouch Token";
    string public constant version = "1";
    uint8 public constant decimals = 18;

    // ** ERC-20 Standard Functions **

    function transfer(address _to, uint256 _value)
        external
        returns (bool success)
    {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)
        external
        returns (bool success)
    {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value)
        external
        returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    // // --- Approve by signature ---
    // function permitted(
    //     address holder,
    //     address spender,
    //     uint256 nonce,
    //     uint256 expiry,
    //     bool isAllowed,
    //     uint8 v,
    //     bytes32 r,
    //     bytes32 s
    // ) public {
    //     bytes32 digest = keccak256(
    //         abi.encodePacked(
    //             "\x19\x01",
    //             DOMAIN_SEPARATOR,
    //             keccak256(
    //                 abi.encode(
    //                     PERMIT_TYPEHASH,
    //                     holder,
    //                     spender,
    //                     nonce,
    //                     expiry,
    //                     isAllowed
    //                 )
    //             )
    //         )
    //     );

    //     require(holder != address(0), "Dai/invalid-address-0");
    //     require(holder == ecrecover(digest, v, r, s), "Dai/invalid-permit");
    //     require(expiry == 0 || now <= expiry, "Dai/permit-expired");
    //     require(nonce == nonces[holder]++, "Dai/invalid-nonce");
    //     uint256 wad = isAllowed ? uint256(-1) : 0;
    //     allowed[holder][spender] = wad;
    //     emit Approval(holder, spender, wad);
    // }

    function supplyOf() external view returns (uint256 balance) {
        return totalSupply;
    }

}

//  ** Inheritance of Pouch Token to Make Delegate Calls to implementation Contract. **

contract PouchDelegate is PouchToken {
    address public admin;
    address cDaiAddress = 0xe7bc397DBd069fC7d0109C0636d06888bb50668c;
    cTokenInterface cDai = cTokenInterface(cDaiAddress);

    address daiAddress = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
    TokenInterface daiToken = TokenInterface(daiAddress);

    address public ImplementationAddress;
    bytes32 public DOMAIN_SEPARATOR;

    bytes32 public constant DEPOSIT_TYPEHASH = keccak256(
        "Deposit(address holder,uint256 value)"
    );
    bytes32 public constant WITHDRAW_TYPEHASH = keccak256(
        "Withdraw(address holder,uint256 value)"
    );
    bytes32 public constant TRANSACT_TYPEHASH = keccak256(
        "Transact(address holder,address to,uint256 value)"
    );

    constructor(uint256 _chainId) public {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                _chainId,
                address(this)
            )
        );

        admin = msg.sender;
    }

    // ** Internal Functions **

    modifier adminOnly() {
        require(msg.sender == admin, "Restricted Access to Admin Only");
        _;
    }

    // ** Update Implementation Address **
    function updateLogic(address _newImplemenationAddress) external adminOnly {
        require(msg.sender == admin, "Admin Only");
        ImplementationAddress = _newImplemenationAddress;
    }

    // ** Delegate Calls **

    // Internal Delegate Function **
    function _ImplementDelegationCore(
        address _holder,
        uint256 _value,
        bytes32 _r,
        bytes32 _s,
        uint8 _v,
        bytes memory logic
    ) internal returns (bool) {
        (bool status, bytes memory returnedData) = ImplementationAddress
            .delegatecall(
            abi.encodeWithSelector(
                bytes4(keccak256(logic)),
                _holder,
                _value,
                _r,
                _s,
                _v
            )
        );
        require(status);
        return abi.decode(returnedData, (bool));
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

    // function deposit(address holder,
    //         uint256 value,
    //         bytes32 r,
    //         bytes32 s,
    //         uint8 v) public returns (bool){
    //           return _ImplementDelegationCore(holder,value,r,s,v, "deposit(address,uint256,bytes32,bytes32,uint8");
    //     }

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
        balances[holder] += value;
        totalSupply += value;
        emit Transfer(address(0), holder, value); // **Mint PCH tokens for the User**
        daiToken.approve(cDaiAddress, value);
        cDai.mint(value); // **Mint cDai  **
        return true;
    }

    // function deposit(
    // // address holder,
    //         uint256 value
    //         // bytes32 r,
    //         // bytes32 s,
    //         // uint8 v
    //         ) public returns (bool){
    //           (bool status, bytes memory returnedData) = ImplementationAddress.delegatecall(abi.encodeWithSelector(bytes4(keccak256("deposit(uint256)")) ,value));
    //         require(status);
    //         return abi.decode(returnedData,(bool));
    //     }

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
        address holder,
        address to,
        uint256 value,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public returns (bool) {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(TRANSACT_TYPEHASH, holder, to, value))
            )
        );

        require(holder != address(0), "Pouch/invalid-address-0");
        require(holder == ecrecover(digest, v, r, s), "Pouch/invalid-permit");
        require(value <= balances[holder], "Insufficient Funds");
        require(to != address(0));

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

    function checkProfits() public view adminOnly returns (uint256) {
        (bool status, bytes memory returnedData) = ImplementationAddress
            .staticcall(
            abi.encodeWithSelector(bytes4(keccak256("_checkProfits()")))
        );
        require(status);
        return abi.decode(returnedData, (uint256));
    }

    function spitProfits() public adminOnly returns (bool) {
        (bool status, bytes memory returnedData) = ImplementationAddress
            .delegatecall(
            abi.encodeWithSelector(bytes4(keccak256("_spitProfits()")))
        );
        require(status);
        return abi.decode(returnedData, (bool));
    }

    /**
     * @notice Delegates execution to an implementation contract
     * @dev It returns to the external caller whatever the implementation returns or forwards reverts
     */
    function() external {
        // delegate all other functions to current implementation
        (bool status, ) = ImplementationAddress.delegatecall(msg.data);
        require(status);

    }

}
