//
// EditUserViewModel.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class EditUserViewModel: Codable {

    public var id: Int?
    public var name: String
    public var roleId: Int


    
    public init(id: Int?, name: String, roleId: Int) {
        self.id = id
        self.name = name
        self.roleId = roleId
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(id, forKey: "id")
        try container.encode(name, forKey: "name")
        try container.encode(roleId, forKey: "roleId")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        id = try container.decodeIfPresent(Int.self, forKey: "id")
        name = try container.decode(String.self, forKey: "name")
        roleId = try container.decode(Int.self, forKey: "roleId")
    }
}

