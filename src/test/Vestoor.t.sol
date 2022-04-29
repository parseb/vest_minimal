// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {Vestoor} from "../Vestoor.sol";

contract VestoorTest is DSTestPlus {
    Vestoor V;

    function setUp() public {
        uint _k = 999999999999999999 * 10 **18;
        V = new Vestoor(_k);
    }

    function testSetVest() public {
        //Vestoor.setVest(token, beneficiary, amount, enddate);
    }
}
