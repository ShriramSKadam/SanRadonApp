//
// UpdateSettingViewModel.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class UpdateSettingViewModel: Codable {

    public var name: String?
    public var value: String?


    
    public init(name: String?, value: String?) {
        self.name = name
        self.value = value
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(name, forKey: "name")
        try container.encodeIfPresent(value, forKey: "value")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        name = try container.decodeIfPresent(String.self, forKey: "name")
        value = try container.decodeIfPresent(String.self, forKey: "value")
    }
}

