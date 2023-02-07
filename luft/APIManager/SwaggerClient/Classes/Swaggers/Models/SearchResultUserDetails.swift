//
// SearchResultUserDetails.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class SearchResultUserDetails: Codable {

    public var totalNoOfRecords: Int64?
    public var records: [UserDetails]?
    public var inspectionIds: [Int64]?


    
    public init(totalNoOfRecords: Int64?, records: [UserDetails]?, inspectionIds: [Int64]?) {
        self.totalNoOfRecords = totalNoOfRecords
        self.records = records
        self.inspectionIds = inspectionIds
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(totalNoOfRecords, forKey: "totalNoOfRecords")
        try container.encodeIfPresent(records, forKey: "records")
        try container.encodeIfPresent(inspectionIds, forKey: "inspectionIds")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        totalNoOfRecords = try container.decodeIfPresent(Int64.self, forKey: "totalNoOfRecords")
        records = try container.decodeIfPresent([UserDetails].self, forKey: "records")
        inspectionIds = try container.decodeIfPresent([Int64].self, forKey: "inspectionIds")
    }
}

