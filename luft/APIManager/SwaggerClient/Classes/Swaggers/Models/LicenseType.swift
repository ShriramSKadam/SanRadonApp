//
// LicenseType.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class LicenseType: Codable {

    public var description: String?
    public var name: String?
    public var createdBy: Int64?
    public var id: Int64?
    public var updatedBy: Int64?


    
    public init(description: String?, name: String?, createdBy: Int64?, id: Int64?, updatedBy: Int64?) {
        self.description = description
        self.name = name
        self.createdBy = createdBy
        self.id = id
        self.updatedBy = updatedBy
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(description, forKey: "description")
        try container.encodeIfPresent(name, forKey: "name")
        try container.encodeIfPresent(createdBy, forKey: "createdBy")
        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(updatedBy, forKey: "updatedBy")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        description = try container.decodeIfPresent(String.self, forKey: "description")
        name = try container.decodeIfPresent(String.self, forKey: "name")
        createdBy = try container.decodeIfPresent(Int64.self, forKey: "createdBy")
        id = try container.decodeIfPresent(Int64.self, forKey: "id")
        updatedBy = try container.decodeIfPresent(Int64.self, forKey: "updatedBy")
    }
}

