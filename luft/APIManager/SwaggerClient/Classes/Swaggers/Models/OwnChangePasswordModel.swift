//
// OwnChangePasswordModel.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class OwnChangePasswordModel: Codable {

    public var id: Int?
    public var oldPassword: String?
    public var newPassword: String?


    
    public init(id: Int?, oldPassword: String?, newPassword: String?) {
        self.id = id
        self.oldPassword = oldPassword
        self.newPassword = newPassword
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(oldPassword, forKey: "oldPassword")
        try container.encodeIfPresent(newPassword, forKey: "newPassword")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        id = try container.decodeIfPresent(Int.self, forKey: "id")
        oldPassword = try container.decodeIfPresent(String.self, forKey: "oldPassword")
        newPassword = try container.decodeIfPresent(String.self, forKey: "newPassword")
    }
}
