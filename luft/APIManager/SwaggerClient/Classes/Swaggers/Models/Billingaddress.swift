//
// Billingaddress.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class Billingaddress: Codable {

    public var address1: String?
    public var address2: String?
    public var city: String?
    public var email: String?
    public var name: String?
    public var phoneNumber: String?
    public var postalCode: String?
    public var stateOrProvince: String?


    
    public init(address1: String?, address2: String?, city: String?, email: String?, name: String?, phoneNumber: String?, postalCode: String?, stateOrProvince: String?) {
        self.address1 = address1
        self.address2 = address2
        self.city = city
        self.email = email
        self.name = name
        self.phoneNumber = phoneNumber
        self.postalCode = postalCode
        self.stateOrProvince = stateOrProvince
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(address1, forKey: "address1")
        try container.encodeIfPresent(address2, forKey: "address2")
        try container.encodeIfPresent(city, forKey: "city")
        try container.encodeIfPresent(email, forKey: "email")
        try container.encodeIfPresent(name, forKey: "name")
        try container.encodeIfPresent(phoneNumber, forKey: "phoneNumber")
        try container.encodeIfPresent(postalCode, forKey: "postalCode")
        try container.encodeIfPresent(stateOrProvince, forKey: "stateOrProvince")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        address1 = try container.decodeIfPresent(String.self, forKey: "address1")
        address2 = try container.decodeIfPresent(String.self, forKey: "address2")
        city = try container.decodeIfPresent(String.self, forKey: "city")
        email = try container.decodeIfPresent(String.self, forKey: "email")
        name = try container.decodeIfPresent(String.self, forKey: "name")
        phoneNumber = try container.decodeIfPresent(String.self, forKey: "phoneNumber")
        postalCode = try container.decodeIfPresent(String.self, forKey: "postalCode")
        stateOrProvince = try container.decodeIfPresent(String.self, forKey: "stateOrProvince")
    }
}

