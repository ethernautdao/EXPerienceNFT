// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./libs/EthernautFactory.sol";

/**
 * @title Soulbound ERC721 implementation - named EXPerienceNFT
 * Requirement:
 *  - Mintable NFT, nontransferable capable of reading and displaying how many EXP tokens you have in your wallet
 *  - Create a fully on-chain generative ASCII art showing numbers from 1 to 100
 *  - All mints start with the number 1
 *  - The number shown by the NFT must reflect the EXP balance of the owner on the NFT
 *  - Transfer capabilities must be disabled after minting (soulbound)
 * @author SolDev-HP (https://github.com/SolDev-HP)
 * @dev Implement ERC721 in a way that limits tokens capabilities such as
 * transfer, approval and make it soulbound - once minted, it can not
 * be transferred
 */
contract EXPerienceNFT is ERC721, Ownable {
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    // EXPToken contract address - To refer to EXP balance of the user
    // Just incase we ever need to change which token should be used to
    // grab balance when generating NFT
    address public EXPContractAddress;

    /*//////////////////////////////////////////////////////////////
                            ERRORS / EVENTS
    //////////////////////////////////////////////////////////////*/

    event EXPTokenContractAddressChange(address indexed _changedToAddress);

    // Error to indicate that action can only be performed by token admins
    error OnlyOnePerAddress();

    // Error to indicate that referenced address is a zero address
    error InvalidAddress();

    /// @dev Error to indicate that token is soulbound and action is not supported
    error TokenIsSoulbound();

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @param _EXPContractAddress address where EXP ERC20 Token is deployed
    constructor(address _owner, address _EXPContractAddress)
        ERC721("EXPerienceNFT", "EXPNFT")
    {
        // Set EXP Contract address
        EXPContractAddress = _EXPContractAddress;

        transferOwnership(_owner);
    }

    /*//////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function changeEXPTokenAddress(address changeTo) public onlyOwner {
        // Validate incoming address
        if (changeTo == address(0)) {
            revert InvalidAddress();
        }

        // Change the address
        EXPContractAddress = changeTo;

        // Emit the event that contract address has been changed
        emit EXPTokenContractAddressChange(changeTo);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Anyone can mint a new NFT
    /// @notice It will display 0 if user has 0 EXP
    function mint() public {
        // Make sure we allow only one NFT mint per address
        if (balanceOf(msg.sender) > 0) {
            revert OnlyOnePerAddress();
        }

        // Increment first so that we can use totalSupply as tokenId
        unchecked {
            ++totalSupply;
        }

        // Mint the EXPerience NFT for the address
        _safeMint(msg.sender, totalSupply);
    }

    /// @notice ASCII art generator
    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        // Make sure tokenId is valid
        require(_exists(tokenId), "Invalid TokenID");

        // Get the owner of the tokenId
        address tokenOwner = ownerOf(tokenId);

        // Get owner's EXP token holdings
        uint256 ownerBal = IERC20(EXPContractAddress).balanceOf(tokenOwner);

        return
            EthernautFactory._generateTokenURI(tokenId, ownerBal, tokenOwner);
    }

    /*//////////////////////////////////////////////////////////////
                            ERC721 FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function approve(address, uint256) public override {
        revert TokenIsSoulbound();
    }

    function getApproved(uint256) public view override returns (address) {
        revert TokenIsSoulbound();
    }

    function setApprovalForAll(address, bool) public override {
        revert TokenIsSoulbound();
    }

    function isApprovedForAll(address, address)
        public
        view
        override
        returns (bool)
    {
        revert TokenIsSoulbound();
    }

    function transferFrom(
        address,
        address,
        uint256
    ) public override {
        revert TokenIsSoulbound();
    }

    function safeTransferFrom(
        address,
        address,
        uint256
    ) public override {
        revert TokenIsSoulbound();
    }

    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes memory
    ) public override {
        revert TokenIsSoulbound();
    }
}
