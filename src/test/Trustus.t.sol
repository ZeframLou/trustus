// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import "forge-std/Test.sol";

import {Trustus} from "../Trustus.sol";
import {TrustusImpl} from "./utils/TrustusImpl.sol";

contract TrustusTest is Test {
    TrustusImpl trustus;
    uint256 constant trustedPK = 1;
    address trustedAddress = vm.addr(trustedPK);
    bytes32 constant request = "GetPrice(address)";
    uint256 deadline = block.timestamp + 100000;
    bytes constant payload = "69420";

    Trustus.TrustusPacket packet;

    function setUp() public {
        trustus = new TrustusImpl(trustedAddress);

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                trustus.DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        keccak256(
                            "VerifyPacket(bytes32 request,uint256 deadline,bytes payload)"
                        ),
                        request,
                        deadline,
                        keccak256(payload)
                    )
                )
            )
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(trustedPK, digest);

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
        vm.warp(deadline + 10);
        assertTrue(trustus.verify(request, packet));
    }

    function testFailWrongSignerParam() public {
        bytes32 fakeR = 0x132026443bc5527254d0e38f3ef3c34d08c6bbea4b19e347ef9b8ef8ff373ead;
        packet.r = fakeR;

        assertTrue(trustus.verify(request, packet));
    }
}
