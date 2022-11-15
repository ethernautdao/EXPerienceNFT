// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IRenderer {
    function render(
        uint256 tokenId,
        uint256 ownerBalance,
        address tokenOwner
    ) external view returns (string memory);
}
