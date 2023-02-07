//
// City.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class City: Codable {

    public var stateId: Int64?
    public var description: String?
    public var name: String?
    public var createdBy: Int64?
    public var id: Int64?
    public var updatedBy: Int64?


    
    public init(stateId: Int64?, description: String?, name: String?, createdBy: Int64?, id: Int64?, updatedBy: Int64?) {
        self.stateId = stateId
        self.description = description
        self.name = name
        self.createdBy = createdBy
        self.id = id
        self.updatedBy = updatedBy
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(stateId, forKey: "stateId")
        try container.encodeIfPresent(description, forKey: "description")
        try container.encodeIfPresent(name, forKey: "name")
        try container.encodeIfPresent(createdBy, forKey: "createdBy")
        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(updatedBy, forKey: "updatedBy")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        stateId = try container.decodeIfPresent(Int64.self, forKey: "stateId")
        description = try container.decodeIfPresent(String.self, forKey: "description")
        name = try container.decodeIfPresent(String.self, forKey: "name")
        createdBy = try container.decodeIfPresent(Int64.self, forKey: "createdBy")
        id = try container.decodeIfPresent(Int64.self, forKey: "id")
        updatedBy = try container.decodeIfPresent(Int64.self, forKey: "updatedBy")
    }
}
