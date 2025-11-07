pragma solidity >=0.8.28;

interface ICollection {
    error FactoryAlreadyInitialized();
    error Unauthorized();

    function tokenId() external view returns (uint256);

    function initialize(
        string memory name,
        string memory symbol,
        address newOwner,
        address defaultRoyaltyReceiver,
        uint96 feeNumerator
    ) external;

    function mint(address to, string memory tokenURI) external returns (uint256 tokenId);

    function canMint(address account) external view returns (bool);
}
