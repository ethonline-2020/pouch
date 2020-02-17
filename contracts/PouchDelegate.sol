pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

import "./PouchToken.sol";

//  ** Inheritance of Pouch Token to Make Delegate Calls to implementation Contract. **

contract PouchDelegate is PouchToken {
    address public admin;
    constructor() public {
        // DOMAIN_SEPARATOR = keccak256(
        //     abi.encode(
        //         keccak256(
        //             "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        //         ),
        //         keccak256(bytes("Pouch")),
        //         keccak256(bytes("1")),
        //         _chainId,
        //         address(this)
        //     )
        // );
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

    function deposit(
        address holder,
        uint256 value,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public returns (bool) {
        return
            _ImplementDelegationCore(
                holder,
                value,
                r,
                s,
                v,
                "deposit(address,uint256,bytes32,bytes32,uint8)"
            );
    }

    function withdraw(
        address holder,
        uint256 value,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public returns (bool) {
        return
            _ImplementDelegationCore(
                holder,
                value,
                r,
                s,
                v,
                "withdraw(address,uint256,bytes32,bytes32,uint8)"
            );
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
                        "transact(address,address,uint256,bytes32,bytes32,uint8)"
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
        require(status, "Transact delegate failed");
        return abi.decode(returnedData, (bool));
    }

    function checkProfits() public view adminOnly returns (uint256) {
        (bool status, bytes memory returnedData) = ImplementationAddress
            .staticcall(
            abi.encodeWithSelector(bytes4(keccak256("checkProfits()")))
        );
        require(status, "checkProfits delegate failed");
        return abi.decode(returnedData, (uint256));
    }

    function spitProfits() public adminOnly returns (bool) {
        (bool status, bytes memory returnedData) = ImplementationAddress
            .delegatecall(
            abi.encodeWithSelector(bytes4(keccak256("spitProfits()")))
        );
        require(status, "splitProfits delegate failed");
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
