//
// ChecklistModel.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class ChecklistModel: Codable {

    public var item: String?
    public var isCompleted: Bool?


    
    public init(item: String?, isCompleted: Bool?) {
        self.item = item
        self.isCompleted = isCompleted
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(item, forKey: "item")
        try container.encodeIfPresent(isCompleted, forKey: "isCompleted")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        item = try container.decodeIfPresent(String.self, forKey: "item")
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: "isCompleted")
    }
}

