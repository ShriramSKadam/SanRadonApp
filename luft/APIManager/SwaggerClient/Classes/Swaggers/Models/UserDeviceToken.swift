//
// UserDeviceToken.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class UserDeviceToken: Codable {

    public var userId: Int64?
    public var deviceId: String?
    public var deviceToken: String?
    public var loginDevice: Int64?
    public var trialAccountExpired: Bool?
    public var userAgentId: String?
    public var ipAddress: String?


    
    public init(userId: Int64?, deviceId: String?, deviceToken: String?, loginDevice: Int64?, trialAccountExpired: Bool?, userAgentId: String?, ipAddress: String?) {
        self.userId = userId
        self.deviceId = deviceId
        self.deviceToken = deviceToken
        self.loginDevice = loginDevice
        self.trialAccountExpired = trialAccountExpired
        self.userAgentId = userAgentId
        self.ipAddress = ipAddress
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(userId, forKey: "userId")
        try container.encodeIfPresent(deviceId, forKey: "deviceId")
        try container.encodeIfPresent(deviceToken, forKey: "deviceToken")
        try container.encodeIfPresent(loginDevice, forKey: "loginDevice")
        try container.encodeIfPresent(trialAccountExpired, forKey: "trialAccountExpired")
        try container.encodeIfPresent(userAgentId, forKey: "userAgentId")
        try container.encodeIfPresent(ipAddress, forKey: "ipAddress")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        userId = try container.decodeIfPresent(Int64.self, forKey: "userId")
        deviceId = try container.decodeIfPresent(String.self, forKey: "deviceId")
        deviceToken = try container.decodeIfPresent(String.self, forKey: "deviceToken")
        loginDevice = try container.decodeIfPresent(Int64.self, forKey: "loginDevice")
        trialAccountExpired = try container.decodeIfPresent(Bool.self, forKey: "trialAccountExpired")
        userAgentId = try container.decodeIfPresent(String.self, forKey: "userAgentId")
        ipAddress = try container.decodeIfPresent(String.self, forKey: "ipAddress")
    }
}

