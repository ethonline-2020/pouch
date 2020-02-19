// TODO: update this to erc20 interface
pragma solidity >=0.5.0;

interface PTokenInterface {
    // mapping(address => uint256) public nonces;
    /// total amount of tokens
    // uint256 public totalSupply;
    // function balanceOf(address owner) external view returns (uint256);
    // function totalSupply() external view returns (uint256);
    // function allowance(address, address) external view returns (uint256);
    // function approve(address, uint256) external returns (bool);
    // function transfer(address, uint256) external returns (bool);
    // function transferFrom(address, address, uint256) external returns (bool);
    // function supplyOf() external view returns (uint256);
    // function permitted(
    //     address,
    //     address,
    //     uint256,
    //     uint256,
    //     bool,
    //     uint8,
    //     bytes32,
    //     bytes32
    // ) external;
    // solhint-disable-next-line no-simple-event-func-name
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}
