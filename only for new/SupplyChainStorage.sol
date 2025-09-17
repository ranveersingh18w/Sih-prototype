// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// This contract ONLY holds data. It has no logic.
contract SupplyChainStorage {
    enum Role { Unknown, Farmer, Collector, Auditor, Manufacturer, Distributor, LabReport }

    struct Actor {
        string actorId;
        string name;
        string addr;
        string phone;
        Role role;
        bool isRegistered;
    }

    struct BlockEntry {
        uint256 index;
        Role role;
        string actorId;
        string name;
        string addr;
        string timeStamp;
        string cropName;
        uint256 quantity;
        string location;
        string batchId;
        uint256 prevIndex;
        uint256 createdAt;
        string ipfsHash;
        string latitude;
        string longitude;
    }

    // Storage variables that the main contract will inherit
    BlockEntry[] internal blocks;
    mapping(string => Actor) internal actors;
    mapping(string => uint256[]) internal batchToIndices;
    mapping(string => string) internal productToBatch;
}