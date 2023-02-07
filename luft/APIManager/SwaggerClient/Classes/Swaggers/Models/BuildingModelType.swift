//
//  ModelType.swift
//  luft
//
//  Created by iMac Augusta on 10/16/19.
//  Copyright © 2019 iMac. All rights reserved.
//

public class BuildingModelType: Codable {
    
    public var description: String?
    public var name: String?
    public var createdBy: Int64?
    public var id: Int64?
    public var updatedBy: Int64?
    public var datecreated: String?
    public var datemodified: String?
    
    
    public init(description: String?, name: String?,datecreated: String?, datemodified: String?, createdBy: Int64?, id: Int64?, updatedBy: Int64?) {
        self.description = description
        self.name = name
        self.createdBy = createdBy
        self.id = id
        self.updatedBy = updatedBy
        self.datecreated = datecreated
        self.datecreated = datemodified
    }
    
    
    // Encodable protocol methods
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: String.self)
        
        try container.encodeIfPresent(description, forKey: "description")
        try container.encodeIfPresent(name, forKey: "name")
        try container.encodeIfPresent(createdBy, forKey: "createdBy")
        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(updatedBy, forKey: "updatedBy")
        try container.encodeIfPresent(datecreated, forKey: "datecreated")
        try container.encodeIfPresent(datemodified, forKey: "datemodified")
    }
    
    // Decodable protocol methods
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)
        
        description = try container.decodeIfPresent(String.self, forKey: "description")
        name = try container.decodeIfPresent(String.self, forKey: "name")
        createdBy = try container.decodeIfPresent(Int64.self, forKey: "createdBy")
        id = try container.decodeIfPresent(Int64.self, forKey: "id")
        updatedBy = try container.decodeIfPresent(Int64.self, forKey: "updatedBy")
        datecreated = try container.decodeIfPresent(String.self, forKey: "datecreated")
        datemodified = try container.decodeIfPresent(String.self, forKey: "datemodified")
        
    }
}

