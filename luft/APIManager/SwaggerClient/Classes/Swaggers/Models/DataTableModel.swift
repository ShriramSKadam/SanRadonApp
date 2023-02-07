//
// DataTableModel.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class DataTableModel: Codable {

    public var dateTime: String?
    public var radon: String?
    public var tempC: String?
    public var pres: String?
    public var humidity: String?
    public var flags: String?
    public var dateSync: Bool?


    
    public init(dateTime: String?, radon: String?, tempC: String?, pres: String?, humidity: String?, flags: String?, dateSync: Bool?) {
        self.dateTime = dateTime
        self.radon = radon
        self.tempC = tempC
        self.pres = pres
        self.humidity = humidity
        self.flags = flags
        self.dateSync = dateSync
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(dateTime, forKey: "dateTime")
        try container.encodeIfPresent(radon, forKey: "radon")
        try container.encodeIfPresent(tempC, forKey: "tempC")
        try container.encodeIfPresent(pres, forKey: "pres")
        try container.encodeIfPresent(humidity, forKey: "humidity")
        try container.encodeIfPresent(flags, forKey: "flags")
        try container.encodeIfPresent(dateSync, forKey: "dateSync")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        dateTime = try container.decodeIfPresent(String.self, forKey: "dateTime")
        radon = try container.decodeIfPresent(String.self, forKey: "radon")
        tempC = try container.decodeIfPresent(String.self, forKey: "tempC")
        pres = try container.decodeIfPresent(String.self, forKey: "pres")
        humidity = try container.decodeIfPresent(String.self, forKey: "humidity")
        flags = try container.decodeIfPresent(String.self, forKey: "flags")
        dateSync = try container.decodeIfPresent(Bool.self, forKey: "dateSync")
    }
}
