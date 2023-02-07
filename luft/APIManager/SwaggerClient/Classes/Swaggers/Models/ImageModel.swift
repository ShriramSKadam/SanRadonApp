//
// ImageModel.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class ImageModel: Codable {

    public var userId: Int64?
    public var imageData: String?


    
    public init(userId: Int64?, imageData: String?) {
        self.userId = userId
        self.imageData = imageData
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(userId, forKey: "userId")
        try container.encodeIfPresent(imageData, forKey: "imageData")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        userId = try container.decodeIfPresent(Int64.self, forKey: "userId")
        imageData = try container.decodeIfPresent(String.self, forKey: "imageData")
    }
}

