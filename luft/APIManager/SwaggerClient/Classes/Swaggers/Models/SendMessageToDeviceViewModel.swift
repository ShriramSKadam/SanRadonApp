//
// SendMessageToDeviceViewModel.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class SendMessageToDeviceViewModel: Codable {

    public var deviceId: Int64?
    public var message: String?


    
    public init(deviceId: Int64?, message: String?) {
        self.deviceId = deviceId
        self.message = message
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(deviceId, forKey: "deviceId")
        try container.encodeIfPresent(message, forKey: "message")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        deviceId = try container.decodeIfPresent(Int64.self, forKey: "deviceId")
        message = try container.decodeIfPresent(String.self, forKey: "message")
    }
}

