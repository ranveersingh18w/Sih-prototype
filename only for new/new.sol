// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import the storage contract so we can use its variables
import "./SupplyChainStorage.sol";

// Inherit from the storage contract by using "is SupplyChainStorage"
contract SupplyChainTrace is SupplyChainStorage {
    
    // --- Custom Errors ---
    error InvalidIndex(uint256 index, uint256 maxIndex);
    error InvalidActor(string actorId);

    // --- Events ---
    event BlockCreated(uint256 indexed index, string batchId, Role role, string actorId);
    event ActorRegistered(string actorId, Role role, string name);

    // --- Modifiers ---
    modifier validPrevIndex(uint256 _prevIndex) {
        if (_prevIndex == 0 || _prevIndex >= blocks.length) {
            revert InvalidIndex(_prevIndex, blocks.length - 1);
        }
        _;
    }

    modifier actorIsRegistered(string memory _actorId) {
        if (!actors[_actorId].isRegistered) {
            revert InvalidActor(_actorId);
        }
        _;
    }

    constructor() {
        blocks.push();
    }

    // ========== Actor Management ==========
    function registerActor(string memory actorId, Role role, string memory name, string memory addr, string memory phone) external {
        actors[actorId] = Actor(actorId, name, addr, phone, role, true);
        emit ActorRegistered(actorId, role, name);
    }
    
    // ========== Internal Helpers ==========
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) { digits++; temp /= 10; }
        bytes memory buffer = new bytes(digits);
        while (value != 0) { digits -= 1; buffer[digits] = bytes1(uint8(48 + (value % 10))); value /= 10; }
        return string(buffer);
    }

    function _generateBatchId(string memory actorId) internal view returns (string memory) {
        return string(abi.encodePacked("B-", actorId, "-", _toString(block.timestamp), "-", _toString(blocks.length)));
    }

    function _createBlock(Role role, string memory actorId, string memory timeStamp, string memory cropName, uint256 quantity, string memory location, string memory batchId, uint256 prevIndex, string memory ipfsHash, string memory latitude, string memory longitude) internal actorIsRegistered(actorId) returns (uint256) {
        Actor storage actor = actors[actorId];
        uint256 newIndex = blocks.length;
        blocks.push(BlockEntry(newIndex, role, actorId, actor.name, actor.addr, timeStamp, cropName, quantity, location, batchId, prevIndex, block.timestamp, ipfsHash, latitude, longitude));
        batchToIndices[batchId].push(newIndex);
        emit BlockCreated(newIndex, batchId, role, actorId);
        return newIndex;
    }

    // ========== Create Block Functions (No changes needed here) ==========
    function createFarmerBlock(string memory farmerId, string memory timeStamp, string memory cropName, uint256 quantity, string memory location, string memory ipfsHash, string memory latitude, string memory longitude) external returns (uint256 index, string memory batchId) {
        batchId = _generateBatchId(farmerId);
        index = _createBlock(Role.Farmer, farmerId, timeStamp, cropName, quantity, location, batchId, 0, ipfsHash, latitude, longitude);
    }

    function createCollectorBlock(string memory collectorId, string memory timeStamp, string memory cropName, uint256 quantity, string memory location, string memory batchId, uint256 prevIndex) external validPrevIndex(prevIndex) returns (uint256) {
        return _createBlock(Role.Collector, collectorId, timeStamp, cropName, quantity, location, batchId, prevIndex, "", "", "");
    }

    function createAuditorBlock(string memory auditorId, string memory timeStamp, string memory cropName, uint256 quantity, string memory location, string memory batchId, uint256 prevIndex) external validPrevIndex(prevIndex) returns (uint256) {
        return _createBlock(Role.Auditor, auditorId, timeStamp, cropName, quantity, location, batchId, prevIndex, "", "", "");
    }

    function createLabReportBlock(string memory labReportId, string memory timeStamp, string memory testCategory, string memory location, string memory batchId, uint256 prevIndex, string memory ipfsHash) external validPrevIndex(prevIndex) returns (uint256) {
        return _createBlock(Role.LabReport, labReportId, timeStamp, testCategory, 0, location, batchId, prevIndex, ipfsHash, "", "");
    }

    function createManufacturerBlock(string memory manufacturerId, string memory timeStamp, string memory productName, uint256 quantity, string memory location, string memory batchId, uint256 prevIndex, string memory productId) external validPrevIndex(prevIndex) returns (uint256) {
        uint256 idx = _createBlock(Role.Manufacturer, manufacturerId, timeStamp, productName, quantity, location, batchId, prevIndex, "", "", "");
        if (bytes(productId).length > 0) { productToBatch[productId] = batchId; }
        return idx;
    }

    function createDistributorBlock(string memory distributorId, string memory timeStamp, string memory productName, uint256 quantity, string memory location, string memory batchId, uint256 prevIndex) external validPrevIndex(prevIndex) returns (uint256) {
        return _createBlock(Role.Distributor, distributorId, timeStamp, productName, quantity, location, batchId, prevIndex, "", "", "");
    }

    // ========== View Functions (No changes needed here) ==========
    function getBlock(uint256 index) public view returns (BlockEntry memory) {
        if (index == 0 || index >= blocks.length) { revert InvalidIndex(index, blocks.length - 1); }
        return blocks[index];
    }

    function getFullChainByBatch(string memory batchId) public view returns (BlockEntry[] memory) {
        uint256[] memory indices = batchToIndices[batchId];
        BlockEntry[] memory result = new BlockEntry[](indices.length);
        for (uint256 i = 0; i < indices.length; i++) { result[i] = blocks[indices[i]]; }
        return result;
    }

    function getBatchIdForProduct(string memory productId) public view returns (string memory) {
        return productToBatch[productId];
    }
}