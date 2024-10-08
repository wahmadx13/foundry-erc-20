//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployAnotherToken} from "script/DeployAnotherToken.s.sol";
import {AnotherToken} from "src/AnotherToken.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract AnotherTokenTest is Test {
    AnotherToken public anotherToken;
    DeployAnotherToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployAnotherToken();
        anotherToken = deployer.run();

        vm.prank(msg.sender);
        anotherToken.transfer(bob, STARTING_BALANCE);
    }

    function testInitialSupply() public {
        assertEq(anotherToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testBobBalance() public {
        assertEq(STARTING_BALANCE, anotherToken.balanceOf(bob));
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(anotherToken)).mint(address(this), 1);
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend tokens on his behalf

        vm.prank(bob);
        anotherToken.approve(alice, initialAllowance);
        uint256 transferAmount = 500;

        vm.prank(alice);
        anotherToken.transferFrom(bob, alice, transferAmount);
        assertEq(anotherToken.balanceOf(alice), transferAmount);
        assertEq(
            anotherToken.balanceOf(bob),
            STARTING_BALANCE - transferAmount
        );
    }
}
