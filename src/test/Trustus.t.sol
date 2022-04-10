// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import {BaseTest, console} from "./base/BaseTest.sol";
import {TrustusImpl} from "./utils/TrustusImpl.sol";
import {Trustus} from "../Trustus.sol";

interface CheatCodes {
    // Set block.timestamp
    function warp(uint256) external;
}

contract TrustusTest is BaseTest {
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    TrustusImpl trustus;
    address trustedAddress = 0x703484b2c3f1e5f4034C27C979Fe600eAf247086;
    bytes32 request = "GetPrice(address)";
    uint256 deadline = block.timestamp + 100000;
    bytes payload = "69420";

    // pre-calculated for the signer trustedAddress and the above request, deadline, payload
    // using ethersjs signer.signDigest(message) method
    bytes32 r =
        0x232026443bc5527254d0e38f3ef3c34d08c6bbea4b19e347ef9b8ef8ff373ead;
    bytes32 s =
        0x15a5fedbef81fad075fe0bf3933a642d457ac7aa57d60e2a00e1f264b4ef983b;
    uint8 v = 28;

    Trustus.TrustusPacket packet;

    function setUp() public {
        trustus = new TrustusImpl(trustedAddress);

        packet = Trustus.TrustusPacket({
            v: v,
            r: r,
            s: s,
            request: request,
            deadline: deadline,
            payload: payload
        });
    }

    function testVerify() public {
        assertTrue(trustus.verify(request, packet));
    }

    function testFailWrongRequest() public {
        bytes32 fakeRequest = "FakeRequest(address)";

        packet.request = fakeRequest;

        assertTrue(trustus.verify(fakeRequest, packet));
    }

    function testFailWrongPayload() public {
        bytes memory fakePayload = "9999999";
        packet.payload = fakePayload;

        assertTrue(trustus.verify(request, packet));
    }

    function testFailOverDeadline() public {
        cheats.warp(deadline + 10);
        assertTrue(trustus.verify(request, packet));
    }

    function testFailWrongSignerParam() public {
        bytes32 fakeR = 0x132026443bc5527254d0e38f3ef3c34d08c6bbea4b19e347ef9b8ef8ff373ead;
        packet.r = fakeR;

        assertTrue(trustus.verify(request, packet));
    }
}
