pragma solidity >=0.8.28;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './interfaces/ICollection.sol';

contract Collection is ERC721Royalty, ERC721URIStorage, Ownable, ICollection {
    string private _name;
    string private _symbol;

    address public factory;

    uint256 public tokenId;

    mapping(address => bool) public canMint;

    constructor() ERC721('', '') {}

    function initialize(
        string memory name_,
        string memory symbol_,
        address newOwner,
        address royaltyReceiver,
        uint96 feeNumerator
    ) external {
        if (factory != address(0)) revert FactoryAlreadyInitialized();
        factory = msg.sender;
        _name = name_;
        _symbol = symbol_;
        _transferOwnership(newOwner);
        if (royaltyReceiver != address(0)) _setDefaultRoyalty(royaltyReceiver, feeNumerator);
        canMint[newOwner] = true;
        canMint[factory] = true;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function mint(address to, string memory tokenURI) external returns (uint256) {
        address sender = msg.sender;
        if (sender != factory && sender != owner() && !canMint[sender]) revert Unauthorized();

        tokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return tokenId;
    }

    function switchMintingRights(address account) external {
        address sender = msg.sender;
        if (sender != factory && sender != owner()) revert Unauthorized();
        canMint[account] = !canMint[account];
    }

    function setDefaultRoyalty(address royaltyReceiver, uint96 feeNumerator) external {
        address sender = msg.sender;
        if (sender != factory && sender != owner()) revert Unauthorized();
        require(royaltyReceiver != address(0), 'ZERO_ADDRESS');

        _setDefaultRoyalty(royaltyReceiver, feeNumerator);
    }

    function setTokenRoyalty(uint256 _tokenId, address royaltyReceiver, uint96 feeNumerator) external {
        address sender = msg.sender;
        if (sender != factory && sender != owner()) revert Unauthorized();
        require(royaltyReceiver != address(0), 'ZERO_ADDRESS');
        require(_ownerOf(_tokenId) != address(0), 'NO_SUCH_TOKEN_ID');
        _setTokenRoyalty(_tokenId, royaltyReceiver, feeNumerator);
    }

    function deleteDefaultRoyalty() external {
        address sender = msg.sender;
        if (sender != factory && sender != owner()) revert Unauthorized();

        _deleteDefaultRoyalty();
    }

    function resetTokenRoyalty(uint256 _tokenId) external {
        address sender = msg.sender;
        if (sender != factory && sender != owner()) revert Unauthorized();

        _resetTokenRoyalty(_tokenId);
    }
}
