//
// NpgsqlPoint.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class NpgsqlPoint: Codable {

    public var x: Double?
    public var y: Double?


    
    public init(x: Double?, y: Double?) {
        self.x = x
        self.y = y
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(x, forKey: "x")
        try container.encodeIfPresent(y, forKey: "y")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        x = try container.decodeIfPresent(Double.self, forKey: "x")
        y = try container.decodeIfPresent(Double.self, forKey: "y")
    }
}

