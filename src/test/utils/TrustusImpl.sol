// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import {Trustus} from "../../Trustus.sol";

/// @notice  Needed for testing since Trustus is abstract
contract TrustusImpl is Trustus {
    constructor(address _trustedAddress) {
        _setIsTrusted(_trustedAddress, true);
    }

    function verify(bytes32 request, Trustus.TrustusPacket calldata packet)
        public
        returns (bool)
    {
        return _verifyPacket(request, packet);
    }
}
