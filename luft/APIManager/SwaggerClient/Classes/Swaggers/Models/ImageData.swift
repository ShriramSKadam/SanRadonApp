//
// ImageData.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class ImageData: Codable {

    public var image: String?
    public var caption: String?


    
    public init(image: String?, caption: String?) {
        self.image = image
        self.caption = caption
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(image, forKey: "image")
        try container.encodeIfPresent(caption, forKey: "caption")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        image = try container.decodeIfPresent(String.self, forKey: "image")
        caption = try container.decodeIfPresent(String.self, forKey: "caption")
    }
}

