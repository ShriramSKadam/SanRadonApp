//
// DeviceCommandOnServer.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class DeviceCommandOnServer: Codable {

    public var serialid: String?
    public var status: String?
    public var token: String?


    
    public init(serialid: String?, status: String?, token: String?) {
        self.serialid = serialid
        self.status = status
        self.token = token
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(serialid, forKey: "serialid")
        try container.encodeIfPresent(status, forKey: "status")
        try container.encodeIfPresent(token, forKey: "token")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        serialid = try container.decodeIfPresent(String.self, forKey: "serialid")
        status = try container.decodeIfPresent(String.self, forKey: "status")
        token = try container.decodeIfPresent(String.self, forKey: "token")
    }
}

