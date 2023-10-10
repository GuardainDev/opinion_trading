// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract OpinionTrading is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155SupplyUpgradeable,
    ERC1155URIStorageUpgradeable,
    ERC1155BurnableUpgradeable,
    UUPSUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIdTracker;

    event MetadataUpdate(uint256 _tokenId);
    event BaseURIUpdated(string previousBaseURI, string newBaseURI);

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string public baseTokenURI;
    string public constant name = "Opinion Trading";
    string public constant symbol = "OPT";

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address admin, string calldata _baseTokenURI) public initializer {
        __ERC1155_init("");
        __AccessControl_init();
        __ERC1155Supply_init();
        __ERC1155Burnable_init();
        __UUPSUpgradeable_init();
        _setBaseURI(_baseTokenURI);
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MINTER_ROLE, ADMIN_ROLE);
        _grantRole(ADMIN_ROLE, admin);
        baseTokenURI = _baseTokenURI;
        _tokenIdTracker.increment();
    }

    function mint(
        address account,
        string calldata cid,
        uint256 supply
    ) external onlyRole(ADMIN_ROLE) returns (uint256 tokenId) {
        require(supply > 0, "invalid supply");
        tokenId = _tokenIdTracker.current();
        _tokenIdTracker.increment();
        _mint(account, tokenId, supply, "");
        _setURI(tokenId, cid);
        return tokenId;
    }

    function mintSupply(
        address account,
        uint256 tokenId,
        uint256 supply
    ) external onlyRole(MINTER_ROLE) returns (bool) {
        require(exists(tokenId), "tokenId not exists");
        _mint(account, tokenId, supply, "");
        return true;
    }

    function batchMintSupply(
        address[] calldata account,
        uint256 tokenId,
        uint256[] calldata supply
    ) external onlyRole(MINTER_ROLE) {
        require(exists(tokenId), "tokenId not exists");
        uint256 supLen = supply.length;
        require(account.length > 0 && account.length == supLen, "invalid args");
        for (uint256 i; i < supLen; ) {
            _mint(account[i], tokenId, supply[i], "");
            unchecked {
                ++i;
            }
        }
    }

    function addMinters(address[] memory _minters) public onlyRole(ADMIN_ROLE) {
        _addMinters(_minters);
    }

    function updateTokenURI(uint256 _tokenId, string calldata _newURI) external onlyRole(MINTER_ROLE) {
        _setURI(_tokenId, _newURI);
        emit MetadataUpdate(_tokenId);
    }

    function setBaseURI(string calldata newBaseTokenURI) external onlyRole(ADMIN_ROLE) {
        _setBaseURI(newBaseTokenURI);
        string memory oldBaseURI = baseTokenURI;
        baseTokenURI = newBaseTokenURI;
        emit BaseURIUpdated(oldBaseURI, newBaseTokenURI);
    }

    function _addMinters(address[] memory _minters) internal {
        for (uint256 i = 0; i < _minters.length; i++) {
            _grantRole(MINTER_ROLE, _minters[i]);
        }
    }

    function uri(
        uint256 tokenId
    ) public view virtual override(ERC1155Upgradeable, ERC1155URIStorageUpgradeable) returns (string memory) {
        return super.uri(tokenId);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(ADMIN_ROLE) {}

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155Upgradeable, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155Upgradeable, ERC1155SupplyUpgradeable) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
