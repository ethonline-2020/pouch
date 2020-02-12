// TODO: delet
pragma solidity >=0.5.0;

contract PTokenInterface {
    mapping(address => uint256) public nonces;
    /// total amount of tokens
    uint256 public totalSupply;
    function allowance(address, address) public view returns (uint256);
    function approve(address, uint256) public returns (bool);
    function transfer(address, uint256) public returns (bool);
    function transferFrom(address, address, uint256) public returns (bool);
    function permitted(
        address,
        address,
        uint256,
        uint256,
        bool,
        uint8,
        bytes32,
        bytes32
    ) public;
    // solhint-disable-next-line no-simple-event-func-name
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}
