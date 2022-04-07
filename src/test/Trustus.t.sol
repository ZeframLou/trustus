// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import {BaseTest, console} from "./base/BaseTest.sol";

contract TrustusTest is BaseTest {
    function setUp() public {}

    function test_trustus() public {
        console.log("just trust us bro");
        assertTrue(true);
    }
}
