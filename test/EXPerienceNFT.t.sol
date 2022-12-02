// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Test} from "forge-std/Test.sol";
import {EXPerienceNFT} from "src/EXPerienceNFT.sol";
import {EXPerienceRenderer} from "src/libs/EXPerienceRenderer.sol";
import {IRenderer} from "src/interfaces/IRenderer.sol";

contract MockEXP {
    function balanceOf(address) public pure returns (uint256) {
        // balance is above 99 EXP, so rendered SVG should display 99
        return 102 ether;
    }
}

contract MockRenderer is IRenderer {
    function render(uint256 tokenId, uint256 ownerBalance, address tokenOwner)
        external
        pure
        override
        returns (string memory)
    {
        return "beep boop";
    }
}

contract EXPerienceNFTTest is Test {
    // from IERC721
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event RendererUpdated(address indexed oldRenderer, address indexed newRenderer);

    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    EXPerienceNFT nftContract;
    MockEXP expContract;
    EXPerienceRenderer renderer;
    address mockRenderer = address(new MockRenderer());

    function setUp() public {
        expContract = new MockEXP();
        renderer = new EXPerienceRenderer();
        nftContract = new EXPerienceNFT(
            owner,
            address(expContract),
            address(renderer)
        );
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

    function testNonOwnerCannotChangeRenderer() public {
        vm.prank(bob);
        vm.expectRevert("Ownable: caller is not the owner");
        nftContract.setRenderer(bob);
    }

    function testOwnerCanChangeRenderer() public {
        // setting the render emits the expected event
        vm.expectEmit(true, true, true, true);
        emit RendererUpdated(address(renderer), mockRenderer);

        vm.prank(owner);
        nftContract.setRenderer(mockRenderer);

        // the renderer is reflected in the getter
        assertEq(address(nftContract.renderer()), address(mockRenderer));

        vm.prank(alice);
        nftContract.mint();

        // the new renderer is active
        assertEq(nftContract.tokenURI(1), "beep boop");
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

        // generated svg: https://codepen.io/beskay/pen/yLEQLJK
    }

    function testCanNotCallTokenURIIfTokenIdDoesNotExist() public {
        vm.prank(alice);
        nftContract.mint();

        vm.expectRevert("ERC721: invalid token ID");
        nftContract.tokenURI(0);
    }
}
