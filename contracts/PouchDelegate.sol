pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

import "./PouchToken.sol";

//  ** Inheritance of Pouch Token to Make Delegate Calls to implementation Contract. **

contract PouchDelegate is PouchToken {
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

    // ** Delegate calls **

    // Deposit delegate call
    function deposit(
        address holder,
        uint256 value,
        uint256 nonce,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public returns (bool) {
        (bool status, bytes memory returnedData) = ImplementationAddress
            .delegatecall(
            abi.encodeWithSelector(
                bytes4(
                    keccak256(
                        "deposit(address,uint256,uint256,bytes32,bytes32,uint8)"
                    )
                ),
                holder,
                value,
                nonce,
                r,
                s,
                v
            )
        );
        require(status);
        return abi.decode(returnedData, (bool));
    }

    // Withdraw delegate call
    function withdraw(
        address holder,
        uint256 value,
        uint256 nonce,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public returns (bool) {
        (bool status, bytes memory returnedData) = ImplementationAddress
            .delegatecall(
            abi.encodeWithSelector(
                bytes4(
                    keccak256(
                        "withdraw(address,uint256,uint256,bytes32,bytes32,uint8)"
                    )
                ),
                holder,
                value,
                nonce,
                r,
                s,
                v
            )
        );
        require(status);
        return abi.decode(returnedData, (bool));
    }

    // Transact delegate call
    function transact(
        address holder,
        address to,
        uint256 value,
        uint256 nonce,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public returns (bool) {
        (bool status, bytes memory returnedData) = ImplementationAddress
            .delegatecall(
            abi.encodeWithSelector(
                bytes4(
                    keccak256(
                        "transact(address,address,uint256,uint256,bytes32,bytes32,uint8)"
                    )
                ),
                holder,
                to,
                value,
                nonce,
                r,
                s,
                v
            )
        );
        require(status);
        return abi.decode(returnedData, (bool));
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
        (bool status, bytes memory returnedData) = ImplementationAddress
            .delegatecall(
            abi.encodeWithSelector(
                bytes4(
                    keccak256(
                        "transactTest(address,address,uint256,uint256,bytes32,bytes32,uint8)"
                    )
                ),
                holder,
                to,
                value,
                nonce,
                r,
                s,
                v
            )
        );
        require(status);
        return abi.decode(returnedData, (bool));

    }

    // Check Profits delegate call
    function checkProfits() public view adminOnly returns (uint256) {
        (bool status, bytes memory returnedData) = ImplementationAddress
            .staticcall(
            abi.encodeWithSelector(bytes4(keccak256("checkProfits()")))
        );
        require(status);
        return abi.decode(returnedData, (uint256));
    }

    // Split Profits delegate call
    function spitProfits() public adminOnly returns (bool) {
        (bool status, bytes memory returnedData) = ImplementationAddress
            .delegatecall(
            abi.encodeWithSelector(bytes4(keccak256("spitProfits()")))
        );
        require(status);
        return abi.decode(returnedData, (bool));
    }

    // function userRewards(address holder) external view returns (uint256) {
    //     return rewards[holder];
    // }
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
