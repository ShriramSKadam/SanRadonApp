//
// RegisterUserViewModel.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** User Registration View Model */

public class RegisterUserViewModel: Codable {

    /** Gets or sets the name. */
    public var name: String?
    /** Gets or sets the email. */
    public var email: String
    /** Gets or sets the mobile. */
    public var mobile: String?
    /** Gets or sets the password. */
    public var password: String


    
    public init(name: String?, email: String, mobile: String?, password: String) {
        self.name = name
        self.email = email
        self.mobile = mobile
        self.password = password
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(name, forKey: "name")
        try container.encode(email, forKey: "email")
        try container.encodeIfPresent(mobile, forKey: "mobile")
        try container.encode(password, forKey: "password")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        name = try container.decodeIfPresent(String.self, forKey: "name")
        email = try container.decode(String.self, forKey: "email")
        mobile = try container.decodeIfPresent(String.self, forKey: "mobile")
        password = try container.decode(String.self, forKey: "password")
    }
}

