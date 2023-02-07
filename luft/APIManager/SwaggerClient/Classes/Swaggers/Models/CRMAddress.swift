//
// CRMAddress.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class CRMAddress: Codable {

    public var street: String?
    public var city: String?
    public var state: String?
    public var country: String?
    public var postalCode: String?


    
    public init(street: String?, city: String?, state: String?, country: String?, postalCode: String?) {
        self.street = street
        self.city = city
        self.state = state
        self.country = country
        self.postalCode = postalCode
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(street, forKey: "street")
        try container.encodeIfPresent(city, forKey: "city")
        try container.encodeIfPresent(state, forKey: "state")
        try container.encodeIfPresent(country, forKey: "country")
        try container.encodeIfPresent(postalCode, forKey: "postalCode")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        street = try container.decodeIfPresent(String.self, forKey: "street")
        city = try container.decodeIfPresent(String.self, forKey: "city")
        state = try container.decodeIfPresent(String.self, forKey: "state")
        country = try container.decodeIfPresent(String.self, forKey: "country")
        postalCode = try container.decodeIfPresent(String.self, forKey: "postalCode")
    }
}

