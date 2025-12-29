// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test, console2} from "forge-std/Test.sol";
import {CustodyAnchor} from "../src/CustodyAnchor.sol";

contract CustodyAnchorTest is Test {
    CustodyAnchor public anchor;
    address public owner;
    address public authorizedAnchor;
    address public unauthorized;

    function setUp() public {
        owner = address(this);
        authorizedAnchor = makeAddr("authorizedAnchor");
        unauthorized = makeAddr("unauthorized");

        anchor = new CustodyAnchor();
        anchor.addAuthorizedAnchor(authorizedAnchor);
    }

    function test_InitialState() public view {
        assertEq(anchor.totalBatches(), 0);
        assertTrue(anchor.isAuthorizedAnchor(owner));
        assertTrue(anchor.isAuthorizedAnchor(authorizedAnchor));
        assertFalse(anchor.isAuthorizedAnchor(unauthorized));
    }

    function test_AnchorBatch() public {
        bytes32 batchId = keccak256("batch1");
        bytes32 merkleRoot = keccak256("root1");
        uint256 eventCount = 10;

        vm.prank(authorizedAnchor);
        anchor.anchorBatch(batchId, merkleRoot, eventCount);

        assertEq(anchor.totalBatches(), 1);

        CustodyAnchor.Batch memory batch = anchor.getBatch(batchId);
        assertEq(batch.merkleRoot, merkleRoot);
        assertEq(batch.eventCount, eventCount);
        assertEq(batch.anchoredBy, authorizedAnchor);
        assertTrue(batch.exists);
    }

    function test_RevertWhen_UnauthorizedAnchor() public {
        bytes32 batchId = keccak256("batch1");
        bytes32 merkleRoot = keccak256("root1");

        vm.expectRevert(CustodyAnchor.UnauthorizedAnchor.selector);
        vm.prank(unauthorized);
        anchor.anchorBatch(batchId, merkleRoot, 10);
    }

    function test_RevertWhen_BatchAlreadyExists() public {
        bytes32 batchId = keccak256("batch1");
        bytes32 merkleRoot = keccak256("root1");

        vm.prank(authorizedAnchor);
        anchor.anchorBatch(batchId, merkleRoot, 10);

        // Intentar anclar el mismo batch de nuevo
        vm.expectRevert(CustodyAnchor.BatchAlreadyExists.selector);
        vm.prank(authorizedAnchor);
        anchor.anchorBatch(batchId, merkleRoot, 10);
    }

    function test_RevertWhen_BatchNotFound() public {
        bytes32 nonExistentBatch = keccak256("nonexistent");
        bytes32 eventHash = keccak256("event");
        bytes32[] memory proof = new bytes32[](1);

        vm.expectRevert(CustodyAnchor.BatchNotFound.selector);
        anchor.verifyEvent(nonExistentBatch, eventHash, proof);
    }

    function test_RevertWhen_InvalidProof() public {
        // Setup batch
        bytes32 leaf1 = keccak256("event1");
        bytes32 leaf2 = keccak256("event2");
        bytes32 merkleRoot = keccak256(abi.encodePacked(leaf1, leaf2));
        bytes32 batchId = keccak256("batch1");

        vm.prank(authorizedAnchor);
        anchor.anchorBatch(batchId, merkleRoot, 2);

        // Usar proof incorrecto
        bytes32[] memory wrongProof = new bytes32[](1);
        wrongProof[0] = keccak256("wrong");

        vm.expectRevert(CustodyAnchor.InvalidProof.selector);
        anchor.verifyEvent(batchId, leaf1, wrongProof);
    }

    function test_VerifyEvent() public {
        // Setup: Create a simple merkle tree with 2 leaves
        bytes32 leaf1 = keccak256("event1");
        bytes32 leaf2 = keccak256("event2");
        bytes32 merkleRoot = keccak256(abi.encodePacked(leaf1, leaf2));

        bytes32 batchId = keccak256("batch1");

        vm.prank(authorizedAnchor);
        anchor.anchorBatch(batchId, merkleRoot, 2);

        // Verify leaf1 with proof [leaf2]
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = leaf2;

        bool isValid = anchor.verifyEvent(batchId, leaf1, proof);
        assertTrue(isValid);
    }

    function test_AddRemoveAuthorizedAnchor() public {
        address newAnchor = makeAddr("newAnchor");

        anchor.addAuthorizedAnchor(newAnchor);
        assertTrue(anchor.isAuthorizedAnchor(newAnchor));

        anchor.removeAuthorizedAnchor(newAnchor);
        assertFalse(anchor.isAuthorizedAnchor(newAnchor));
    }

    function testFuzz_AnchorBatch(bytes32 batchId, bytes32 merkleRoot, uint256 eventCount) public {
        vm.assume(eventCount > 0 && eventCount < 1000000);

        vm.prank(authorizedAnchor);
        anchor.anchorBatch(batchId, merkleRoot, eventCount);

        CustodyAnchor.Batch memory batch = anchor.getBatch(batchId);
        assertEq(batch.merkleRoot, merkleRoot);
        assertEq(batch.eventCount, eventCount);
    }

    function test_EmitsCustodyBatchAnchored() public {
        bytes32 batchId = keccak256("batch1");
        bytes32 merkleRoot = keccak256("root1");
        uint256 eventCount = 10;

        vm.expectEmit(true, true, false, true);
        emit CustodyAnchor.CustodyBatchAnchored(batchId, merkleRoot, block.timestamp, authorizedAnchor);

        vm.prank(authorizedAnchor);
        anchor.anchorBatch(batchId, merkleRoot, eventCount);
    }

    function test_EmitsCustodyEventVerified() public {
        bytes32 leaf1 = keccak256("event1");
        bytes32 leaf2 = keccak256("event2");
        bytes32 merkleRoot = keccak256(abi.encodePacked(leaf1, leaf2));
        bytes32 batchId = keccak256("batch1");

        vm.prank(authorizedAnchor);
        anchor.anchorBatch(batchId, merkleRoot, 2);

        bytes32[] memory proof = new bytes32[](1);
        proof[0] = leaf2;

        vm.expectEmit(true, true, false, true);
        emit CustodyAnchor.CustodyEventVerified(batchId, leaf1, address(this));

        anchor.verifyEvent(batchId, leaf1, proof);
    }
}