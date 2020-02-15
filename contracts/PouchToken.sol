pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

import "./interfaces/TokenInterface.sol";
import "./interfaces/cTokenInterface.sol";
import "./interfaces/PTokenInterface.sol";

contract PouchToken is PTokenInterface {
    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    address public ImplementationAddress;
    address public admin;
    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH = keccak256(
        "Permit(address holder,address spender,uint256 nonce,uint256 expiry,bool isAllowed)"
    );
    mapping(address => uint256) public nonces;
    uint256 private constant MAX_UINT256 = uint256(-1);

    bytes32 public constant DEPOSIT_TYPEHASH = keccak256(
        "Deposit(address holder,uint256 value)"
    );
    bytes32 public constant WITHDRAW_TYPEHASH = keccak256(
        "Withdraw(address holder,uint256 value)"
    );

    address daiAddress = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
    address cDaiAddress = 0xe7bc397DBd069fC7d0109C0636d06888bb50668c;
    address pDaiAddress = 0xb5cea18Db04008a4D68444A298DBDD2D0E442E3D;

    TokenInterface daiToken = TokenInterface(daiAddress);
    cTokenInterface cDai = cTokenInterface(cDaiAddress);
    PTokenInterface pDaiToken = PTokenInterface(pDaiAddress);

    // --- ERC20 Data ---
    string public constant name = "Pouch Token";
    string public constant symbol = "PCH";
    string public constant version = "1";
    uint8 public constant decimals = 18;

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

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)
        public
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
        public
        returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    // --- Approve by signature ---
    function permitted(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool isAllowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        holder,
                        spender,
                        nonce,
                        expiry,
                        isAllowed
                    )
                )
            )
        );

        require(holder != address(0), "Dai/invalid-address-0");
        require(holder == ecrecover(digest, v, r, s), "Dai/invalid-permit");
        require(expiry == 0 || now <= expiry, "Dai/permit-expired");
        require(nonce == nonces[holder]++, "Dai/invalid-nonce");
        uint256 wad = isAllowed ? uint256(-1) : 0;
        allowed[holder][spender] = wad;
        emit Approval(holder, spender, wad);
    }

    // ** Proxy **

    function updateLogic(address _newImplemenationAddress) external {
        require(msg.sender == admin, "Admin Only");
        ImplementationAddress = _newImplemenationAddress;
    }

    function deposit(
        address holder,
        uint256 value,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public returns (bool) {
        (bool status, bytes memory returnedData) = ImplementationAddress
            .delegatecall(
            abi.encodeWithSelector(
                bytes4(
                    keccak256("_deposit(address,uint256,bytes32,bytes32,uint8)")
                ),
                holder,
                value,
                r,
                s,
                v
            )
        );
        require(status);
        return abi.decode(returnedData, (bool));
    }

    function withdraw(
        address holder,
        uint256 value,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public returns (bool) {
        (bool status, bytes memory returnedData) = ImplementationAddress
            .delegatecall(
            abi.encodeWithSelector(
                bytes4(
                    keccak256(
                        "_withdraw(address,uint256,bytes32,bytes32,uint8)"
                    )
                ),
                holder,
                value,
                r,
                s,
                v
            )
        );
        require(status);
        return abi.decode(returnedData, (bool));
    }

    function transact(
        address holder,
        address to,
        uint256 value,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public returns (bool) {
        (bool status, bytes memory returnedData) = ImplementationAddress
            .delegatecall(
            abi.encodeWithSelector(
                bytes4(
                    keccak256(
                        "_transact(address,address,uint256,bytes32,bytes32,uint8)"
                    )
                ),
                holder,
                to,
                value,
                r,
                s,
                v
            )
        );
        require(status);
        return abi.decode(returnedData, (bool));
    }

    function checkProfits() public returns (uint256) {
        (bool status, bytes memory returnedData) = ImplementationAddress
            .delegatecall(
            abi.encodeWithSelector(bytes4(keccak256("_checkProfits()")))
        );
        require(status);
        return abi.decode(returnedData, (uint256));
    }

    function spitProfits() public returns (bool) {
        (bool status, bytes memory returnedData) = ImplementationAddress
            .delegatecall(
            abi.encodeWithSelector(bytes4(keccak256("_spitProfits()")))
        );
        require(status);
        return abi.decode(returnedData, (bool));
    }

}
