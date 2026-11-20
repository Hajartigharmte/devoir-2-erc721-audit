// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CertificateRegistryERC721 is ERC721URIStorage, AccessControl, ReentrancyGuard {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    struct Certificate {
        string studentId;
        string studentName;
        string diplomaTitle;
        uint256 issuedAt;
        bool revoked;
        bool exists;
    }

    uint256 private _nextTokenId = 1;
    mapping(uint256 => Certificate) private _certificates;
    mapping(bytes32 => bool) private _usedStudentIdHashes;

    event CertificateMinted(
        uint256 indexed tokenId,
        address indexed recipient,
        string studentId,
        string tokenURI
    );

    event CertificateRevoked(
        uint256 indexed tokenId,
        address indexed revokedBy
    );

    constructor(address admin) ERC721("AcademicCertificate", "CERT") {
        require(admin != address(0), "Admin address cannot be zero");
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
    }

    function mintCertificate(
        address to,
        string calldata studentId,
        string calldata studentName,
        string calldata diplomaTitle,
        string calldata uri
    ) external onlyRole(MINTER_ROLE) nonReentrant returns (uint256) {
        require(to != address(0), "Recipient cannot be zero address");
        require(bytes(studentId).length > 0, "Student ID cannot be empty");
        require(bytes(studentName).length > 0, "Student name cannot be empty");
        require(bytes(diplomaTitle).length > 0, "Diploma title cannot be empty");
        require(bytes(uri).length > 0, "Token URI cannot be empty");

        bytes32 studentHash = keccak256(abi.encodePacked(studentId));
        require(!_usedStudentIdHashes[studentHash], "Student ID already minted");
        _usedStudentIdHashes[studentHash] = true;

        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        _certificates[tokenId] = Certificate({
            studentId: studentId,
            studentName: studentName,
            diplomaTitle: diplomaTitle,
            issuedAt: block.timestamp,
            revoked: false,
            exists: true
        });

        emit CertificateMinted(tokenId, to, studentId, uri);
        return tokenId;
    }

    function batchMintCertificates(
        address[] calldata to,
        string[] calldata studentIds,
        string[] calldata studentNames,
        string[] calldata diplomaTitles,
        string[] calldata uris
    ) external onlyRole(MINTER_ROLE) nonReentrant {
        uint256 count = to.length;
        require(count > 0, "Empty batch");
        require(
            count == studentIds.length &&
            count == studentNames.length &&
            count == diplomaTitles.length &&
            count == uris.length,
            "Array lengths mismatch"
        );

        for (uint256 i = 0; i < count; i++) {
            require(to[i] != address(0), "Recipient cannot be zero address");
            require(bytes(studentIds[i]).length > 0, "Student ID cannot be empty");
            require(bytes(studentNames[i]).length > 0, "Student name cannot be empty");
            require(bytes(diplomaTitles[i]).length > 0, "Diploma title cannot be empty");
            require(bytes(uris[i]).length > 0, "Token URI cannot be empty");

            bytes32 studentHash = keccak256(abi.encodePacked(studentIds[i]));
            require(!_usedStudentIdHashes[studentHash], "Student ID already minted");
            _usedStudentIdHashes[studentHash] = true;

            uint256 tokenId = _nextTokenId++;
            _safeMint(to[i], tokenId);
            _setTokenURI(tokenId, uris[i]);

            _certificates[tokenId] = Certificate({
                studentId: studentIds[i],
                studentName: studentNames[i],
                diplomaTitle: diplomaTitles[i],
                issuedAt: block.timestamp,
                revoked: false,
                exists: true
            });

            emit CertificateMinted(tokenId, to[i], studentIds[i], uris[i]);
        }
    }

    function revokeCertificate(uint256 tokenId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_certificates[tokenId].exists, "Certificate does not exist");
        require(!_certificates[tokenId].revoked, "Certificate already revoked");

        _certificates[tokenId].revoked = true;
        emit CertificateRevoked(tokenId, msg.sender);
    }

    function getCertificate(uint256 tokenId)
        external
        view
        returns (
            string memory studentId,
            string memory studentName,
            string memory diplomaTitle,
            uint256 issuedAt,
            bool revoked,
            string memory uri
        )
    {
        require(_certificates[tokenId].exists, "Certificate does not exist");
        Certificate storage cert = _certificates[tokenId];
        return (
            cert.studentId,
            cert.studentName,
            cert.diplomaTitle,
            cert.issuedAt,
            cert.revoked,
            tokenURI(tokenId)
        );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}