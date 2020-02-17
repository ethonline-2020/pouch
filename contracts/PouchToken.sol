pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

import "./interfaces/PTokenInterface.sol";

contract PouchToken is PTokenInterface {
    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    address public ImplementationAddress;
    // bytes32 public DOMAIN_SEPARATOR;
    // address cDaiAddress = 0xe7bc397DBd069fC7d0109C0636d06888bb50668c;
    // address daiAddress = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;

    // mapping(address => uint256) public nonces;
    // bytes32 public constant PERMIT_TYPEHASH = keccak256(
    //     "Permit(address holder,address spender,uint256 nonce,uint256 expiry,bool isAllowed)"
    // );
    uint256 private constant MAX_UINT256 = uint256(-1);

    // --- ERC20 Data ---
    string public constant name = "Pouch Token";
    string public constant symbol = "PCH";
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

    // --- Approve by signature ---
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

    // function totalSupply() external view returns (uint256) {
    //     return totalSupply;
    // }

}
