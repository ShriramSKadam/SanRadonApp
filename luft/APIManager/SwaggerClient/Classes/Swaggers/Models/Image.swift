//
// Image.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class Image: Codable {

    public var inspectionId: Int64?
    public var isCoverPhoto: Bool?
    public var imageData: String?
    public var caption: String?
    public var imageHash: String?
    public var createdBy: Int64?
    public var id: Int64?
    public var updatedBy: Int64?


    
    public init(inspectionId: Int64?, isCoverPhoto: Bool?, imageData: String?, caption: String?, imageHash: String?, createdBy: Int64?, id: Int64?, updatedBy: Int64?) {
        self.inspectionId = inspectionId
        self.isCoverPhoto = isCoverPhoto
        self.imageData = imageData
        self.caption = caption
        self.imageHash = imageHash
        self.createdBy = createdBy
        self.id = id
        self.updatedBy = updatedBy
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(inspectionId, forKey: "inspectionId")
        try container.encodeIfPresent(isCoverPhoto, forKey: "isCoverPhoto")
        try container.encodeIfPresent(imageData, forKey: "imageData")
        try container.encodeIfPresent(caption, forKey: "caption")
        try container.encodeIfPresent(imageHash, forKey: "imageHash")
        try container.encodeIfPresent(createdBy, forKey: "createdBy")
        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(updatedBy, forKey: "updatedBy")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        inspectionId = try container.decodeIfPresent(Int64.self, forKey: "inspectionId")
        isCoverPhoto = try container.decodeIfPresent(Bool.self, forKey: "isCoverPhoto")
        imageData = try container.decodeIfPresent(String.self, forKey: "imageData")
        caption = try container.decodeIfPresent(String.self, forKey: "caption")
        imageHash = try container.decodeIfPresent(String.self, forKey: "imageHash")
        createdBy = try container.decodeIfPresent(Int64.self, forKey: "createdBy")
        id = try container.decodeIfPresent(Int64.self, forKey: "id")
        updatedBy = try container.decodeIfPresent(Int64.self, forKey: "updatedBy")
    }
}
