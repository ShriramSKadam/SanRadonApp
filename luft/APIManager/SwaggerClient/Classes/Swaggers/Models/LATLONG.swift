//
// LATLONG.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class LATLONG: Codable {

    public var latitude: Double?
    public var longitude: Double?


    
    public init(latitude: Double?, longitude: Double?) {
        self.latitude = latitude
        self.longitude = longitude
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(latitude, forKey: "latitude")
        try container.encodeIfPresent(longitude, forKey: "longitude")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        latitude = try container.decodeIfPresent(Double.self, forKey: "latitude")
        longitude = try container.decodeIfPresent(Double.self, forKey: "longitude")
    }
}

