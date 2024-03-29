//
// DeviceReadingBoundsModel.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class DeviceReadingBoundsModel: Codable {

    public var minLogIndex: Int64?
    public var maxLogIndex: Int64?


    
    public init(minLogIndex: Int64?, maxLogIndex: Int64?) {
        self.minLogIndex = minLogIndex
        self.maxLogIndex = maxLogIndex
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(minLogIndex, forKey: "minLogIndex")
        try container.encodeIfPresent(maxLogIndex, forKey: "maxLogIndex")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        minLogIndex = try container.decodeIfPresent(Int64.self, forKey: "minLogIndex")
        maxLogIndex = try container.decodeIfPresent(Int64.self, forKey: "maxLogIndex")
    }
}

