//
// Actionlevel.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class Actionlevel: Codable {

    public var k: String?
    public var v: Int?


    
    public init(k: String?, v: Int?) {
        self.k = k
        self.v = v
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(k, forKey: "k")
        try container.encodeIfPresent(v, forKey: "v")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        k = try container.decodeIfPresent(String.self, forKey: "k")
        v = try container.decodeIfPresent(Int.self, forKey: "v")
    }
}
