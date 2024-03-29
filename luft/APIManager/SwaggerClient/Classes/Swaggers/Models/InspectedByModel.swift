//
// InspectedByModel.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class InspectedByModel: Codable {

    public var name: String?
    public var address: String?
    public var city: String?
    public var state: String?
    public var zipcode: String?
    public var contact: String?
    public var isSelectLicense: Bool?
    public var license: String?


    
    public init(name: String?, address: String?, city: String?, state: String?, zipcode: String?, contact: String?, isSelectLicense: Bool?, license: String?) {
        self.name = name
        self.address = address
        self.city = city
        self.state = state
        self.zipcode = zipcode
        self.contact = contact
        self.isSelectLicense = isSelectLicense
        self.license = license
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(name, forKey: "name")
        try container.encodeIfPresent(address, forKey: "address")
        try container.encodeIfPresent(city, forKey: "city")
        try container.encodeIfPresent(state, forKey: "state")
        try container.encodeIfPresent(zipcode, forKey: "zipcode")
        try container.encodeIfPresent(contact, forKey: "contact")
        try container.encodeIfPresent(isSelectLicense, forKey: "isSelectLicense")
        try container.encodeIfPresent(license, forKey: "license")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        name = try container.decodeIfPresent(String.self, forKey: "name")
        address = try container.decodeIfPresent(String.self, forKey: "address")
        city = try container.decodeIfPresent(String.self, forKey: "city")
        state = try container.decodeIfPresent(String.self, forKey: "state")
        zipcode = try container.decodeIfPresent(String.self, forKey: "zipcode")
        contact = try container.decodeIfPresent(String.self, forKey: "contact")
        isSelectLicense = try container.decodeIfPresent(Bool.self, forKey: "isSelectLicense")
        license = try container.decodeIfPresent(String.self, forKey: "license")
    }
}

