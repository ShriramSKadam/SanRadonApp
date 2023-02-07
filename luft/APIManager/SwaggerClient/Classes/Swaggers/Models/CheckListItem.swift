//
// Checklistitem.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class Checklistitem: Codable {

    public var canEdit: Bool?
    public var isChecked: Bool?
    public var text: String?


    
    public init(canEdit: Bool?, isChecked: Bool?, text: String?) {
        self.canEdit = canEdit
        self.isChecked = isChecked
        self.text = text
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(canEdit, forKey: "canEdit")
        try container.encodeIfPresent(isChecked, forKey: "isChecked")
        try container.encodeIfPresent(text, forKey: "text")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        canEdit = try container.decodeIfPresent(Bool.self, forKey: "canEdit")
        isChecked = try container.decodeIfPresent(Bool.self, forKey: "isChecked")
        text = try container.decodeIfPresent(String.self, forKey: "text")
    }
}
