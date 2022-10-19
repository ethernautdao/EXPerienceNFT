// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Test} from "forge-std/Test.sol";
import {EXPerienceNFT} from "src/EXPerienceNFT.sol";

contract MockEXP {
    function balanceOf(address) public pure returns (uint256) {
        return 42;
    }
}

contract EXPerienceNFTTest is Test {
    // from IERC721
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    EXPerienceNFT nftContract;
    MockEXP expContract;

    function setUp() public {
        expContract = new MockEXP();
        nftContract = new EXPerienceNFT(owner, address(expContract));
    }

    function testNonOwnerCannotChangeEXPContractAddress() public {
        vm.prank(bob);
        vm.expectRevert("Ownable: caller is not the owner");
        nftContract.changeEXPTokenAddress(bob);
    }

    function testOwnerCanChangeEXPContractAddress() public {
        address newAddr = makeAddr("newAddr");

        vm.prank(owner);
        nftContract.changeEXPTokenAddress(newAddr);

        assertEq(nftContract.EXPContractAddress(), newAddr);
    }

    function testAnyoneCanMint() public {
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), alice, 1);

        vm.prank(alice);
        nftContract.mint();

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), bob, 2);

        vm.prank(bob);
        nftContract.mint();
    }

    function testCanOnlyMintOnce() public {
        vm.startPrank(alice);
        nftContract.mint();

        vm.expectRevert(abi.encodeWithSignature("OnlyOnePerAddress()"));
        nftContract.mint();
        vm.stopPrank();
    }

    function testCanNotTransfer() public {
        vm.startPrank(alice);
        nftContract.mint();

        vm.expectRevert(abi.encodeWithSignature("TokenIsSoulbound()"));
        nftContract.transferFrom(alice, bob, 1);

        vm.expectRevert(abi.encodeWithSignature("TokenIsSoulbound()"));
        nftContract.safeTransferFrom(alice, bob, 1);

        vm.expectRevert(abi.encodeWithSignature("TokenIsSoulbound()"));
        nftContract.safeTransferFrom(alice, bob, 1, "");

        vm.stopPrank();
    }

    function testCanCallTokenURI() public {
        vm.prank(alice);
        nftContract.mint();

        string memory tokenURI = nftContract.tokenURI(1);
        assertGt(bytes(tokenURI).length, 0);
    }

    function testCanNotCallTokenURIIfTokenIdDoesNotExist() public {
        vm.prank(alice);
        nftContract.mint();

        vm.expectRevert("Invalid TokenID");
        nftContract.tokenURI(0);
    }
}
