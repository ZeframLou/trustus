// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

abstract contract Trustus {
    /// -----------------------------------------------------------------------
    /// Structs
    /// -----------------------------------------------------------------------

    struct TrustusPacket {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
        bytes payload;
    }

    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    error Trustus__InvalidPacket();

    /// -----------------------------------------------------------------------
    /// Immutable parameters
    /// -----------------------------------------------------------------------

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    /// -----------------------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------------------

    mapping(address => bool) internal isTrusted;

    /// -----------------------------------------------------------------------
    /// Modifiers
    /// -----------------------------------------------------------------------

    modifier verifyPacket(TrustusPacket calldata packet) {
        if (!_verifyPacket(packet)) revert Trustus__InvalidPacket();
        _;
    }

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor() {
        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = _computeDomainSeparator();
    }

    /// -----------------------------------------------------------------------
    /// Packet verification
    /// -----------------------------------------------------------------------

    function _verifyPacket(TrustusPacket calldata packet)
        internal
        virtual
        returns (bool success)
    {
        // verify deadline
        if (block.timestamp > packet.deadline) return false;

        // verify signature
        address recoveredAddress = ecrecover(
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            keccak256(
                                "VerifyPacket(uint256 deadline,bytes payload)"
                            ),
                            packet.deadline,
                            packet.payload
                        )
                    )
                )
            ),
            packet.v,
            packet.r,
            packet.s
        );
        return (recoveredAddress != address(0)) && isTrusted[recoveredAddress];
    }

    function _setIsTrusted(address signer, bool isTrusted_) internal virtual {
        isTrusted[signer] = isTrusted_;
    }

    /// -----------------------------------------------------------------------
    /// EIP-2612 compliance
    /// -----------------------------------------------------------------------

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return
            block.chainid == INITIAL_CHAIN_ID
                ? INITIAL_DOMAIN_SEPARATOR
                : _computeDomainSeparator();
    }

    function _computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256("Trustus"),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }
}
