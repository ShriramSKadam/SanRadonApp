//
// CalibrationFactor.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class CalibrationFactor: Codable {

    public var inspectionId: Int64?
    public var value: Double?
    public var createdBy: Int64?
    public var id: Int64?
    public var updatedBy: Int64?


    
    public init(inspectionId: Int64?, value: Double?, createdBy: Int64?, id: Int64?, updatedBy: Int64?) {
        self.inspectionId = inspectionId
        self.value = value
        self.createdBy = createdBy
        self.id = id
        self.updatedBy = updatedBy
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(inspectionId, forKey: "inspectionId")
        try container.encodeIfPresent(value, forKey: "value")
        try container.encodeIfPresent(createdBy, forKey: "createdBy")
        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(updatedBy, forKey: "updatedBy")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        inspectionId = try container.decodeIfPresent(Int64.self, forKey: "inspectionId")
        value = try container.decodeIfPresent(Double.self, forKey: "value")
        createdBy = try container.decodeIfPresent(Int64.self, forKey: "createdBy")
        id = try container.decodeIfPresent(Int64.self, forKey: "id")
        updatedBy = try container.decodeIfPresent(Int64.self, forKey: "updatedBy")
    }
}

