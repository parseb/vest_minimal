// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {Vestoor} from "../Vestoor.sol";
import {MockERC20} from "./utils/MockERC20.sol";


contract VestoorTest is DSTestPlus {
    Vestoor V;
    MockERC20 E;
    address eAddr;
    uint256 oneToken;
    uint256 k;

    function setUp() public {
        k = 999999999999999999 * 10 **18;
        E = new MockERC20();
        V = new Vestoor(k);
        oneToken = 1e18;
        eAddr = address(E);

        E.approve(address(V), type(uint256).max - 1);
    }

    function testSetVest(uint32 _ammount) public {
        uint256 endD = block.timestamp + 20000;
        uint256 ammount = uint256(_ammount) + endD + 1;
        V.setVest(eAddr, address(1), ammount, endD);
        bool s = V.getVest(eAddr, address(1)) == (ammount* k) + endD;
        assertTrue(s);
    }
}
