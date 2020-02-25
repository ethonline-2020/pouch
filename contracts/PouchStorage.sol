pragma solidity >=0.5.0;

import "./interfaces/TokenInterface.sol";
import "./interfaces/cTokenInterface.sol";

contract PouchStorage {
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
    mapping(address => uint256) public rewards;
}
