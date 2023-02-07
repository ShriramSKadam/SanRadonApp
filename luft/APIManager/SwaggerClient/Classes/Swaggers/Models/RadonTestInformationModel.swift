//
// RadonTestInformationModel.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class RadonTestInformationModel: Codable {

    public var radonRiskInformation: String?
    public var understandingRadonTestResults: String?
    public var stateNoticeToClient: String?
    public var stateName: String?


    
    public init(radonRiskInformation: String?, understandingRadonTestResults: String?, stateNoticeToClient: String?, stateName: String?) {
        self.radonRiskInformation = radonRiskInformation
        self.understandingRadonTestResults = understandingRadonTestResults
        self.stateNoticeToClient = stateNoticeToClient
        self.stateName = stateName
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(radonRiskInformation, forKey: "radonRiskInformation")
        try container.encodeIfPresent(understandingRadonTestResults, forKey: "understandingRadonTestResults")
        try container.encodeIfPresent(stateNoticeToClient, forKey: "stateNoticeToClient")
        try container.encodeIfPresent(stateName, forKey: "stateName")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        radonRiskInformation = try container.decodeIfPresent(String.self, forKey: "radonRiskInformation")
        understandingRadonTestResults = try container.decodeIfPresent(String.self, forKey: "understandingRadonTestResults")
        stateNoticeToClient = try container.decodeIfPresent(String.self, forKey: "stateNoticeToClient")
        stateName = try container.decodeIfPresent(String.self, forKey: "stateName")
    }
}

