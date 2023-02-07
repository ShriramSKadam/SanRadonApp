//
// ChangePasswordViewModel.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** model for Changing password */

public class ChangePasswordViewModel: Codable {

    /** Gets or sets the identifier. */
    public var id: Int
    /** Gets or sets the password. */
    public var password: String


    
    public init(id: Int, password: String) {
        self.id = id
        self.password = password
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encode(id, forKey: "id")
        try container.encode(password, forKey: "password")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        id = try container.decode(Int.self, forKey: "id")
        password = try container.decode(String.self, forKey: "password")
    }
}

