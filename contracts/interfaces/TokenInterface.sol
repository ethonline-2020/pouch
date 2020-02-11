// TODO: delet
pragma solidity >=0.5.0;

contract TokenInterface {
    mapping(address => uint256) public nonces;
    function allowance(address, address) external view returns (uint256);
    function approve(address, uint256) external;
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function permit(
        address,
        address,
        uint256,
        uint256,
        bool,
        uint8,
        bytes32,
        bytes32
    ) external;
}
