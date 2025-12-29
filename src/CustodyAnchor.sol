// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title CustodyAnchor
 * @notice Anchors custody events from Hyperledger Fabric to L2
 * @dev Stores Merkle roots of custody batches for verification
 */

contract CustodyAnchor is Ownable {
    // Events
    event CustodyBatchAnchored(
        bytes32 indexed batchId,
        bytes32 merkleRoot,
        uint256 timestamp,
        address indexed anchor
    );

    event CustodyEventVerified(
        bytes32 indexed batchId,
        bytes32 eventHash,
        address indexed verifier
    );
    //Structs
    struct Batch {
        bytes32 merkleRoot;
        uint256 timestamp;
        address anchoredBy;
        uint256 eventCount;
        bool exists;
    }
    //State variables
    mapping(bytes32 => Batch) public batches;
    mapping(address => bool) public authorizedAnchors;
    uint64 public totalBatches;

    //Errors Management
    error UnauthorizedAnchor();
    error BatchAlreadyExists();
    error BatchNotFound();
    error InvalidProof();

    constructor() Ownable(msg.sender) {
        authorizedAnchors[msg.sender] =true;
    }

    //Admin functions
    function addAuthorizedAnchor(address anchor) external onlyOwner {
        authorizedAnchors[anchor] = true;
    }

    function removeAuthorizedAnchor(address anchor) external onlyOwner{
        authorizedAnchors[anchor] = false;
    }

    // Core functions
    function anchorBatch(
        bytes32 batchId,
        bytes32 merkleRoot,
        uint256 eventCount
    ) external {
        if (!authorizedAnchors[msg.sender]) revert UnauthorizedAnchor();
        if (batches[batchId].exists) revert BatchAlreadyExists();

        batches[batchId] = Batch({
            merkleRoot: merkleRoot,
            timestamp: block.timestamp,
            anchoredBy: msg.sender,
            eventCount: eventCount,
            exists: true

    });

    totalBatches++;

    emit CustodyBatchAnchored(batchId, merkleRoot, block.timestamp, msg.sender);
    }

    function verifyEvent(
        bytes32 batchId,
        bytes32 eventHash,
        bytes32[] calldata proof
    ) external returns (bool) {
        Batch memory batch = batches[batchId];
        if (!batch.exists) revert BatchNotFound();

        bool isValid = MerkleProof.verify(proof, batch.merkleRoot, eventHash);
        if (!isValid) revert InvalidProof();

        emit CustodyEventVerified(batchId, eventHash, msg.sender);
        return true;
    }
    //View functions
    function getBatch(bytes32 batchId) external view returns (Batch memory){
        return batches[batchId];
    }

    function isAuthorizedAnchor(address anchor) external view returns (bool){
        return authorizedAnchors[anchor];
    }

}
