//
// ReadingAggregationViewModel.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class ReadingAggregationViewModel: Codable {

    public var period: String?
    public var value: Double?
    public var readingItemName: String?


    
    public init(period: String?, value: Double?, readingItemName: String?) {
        self.period = period
        self.value = value
        self.readingItemName = readingItemName
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(period, forKey: "period")
        try container.encodeIfPresent(value, forKey: "value")
        try container.encodeIfPresent(readingItemName, forKey: "readingItemName")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        period = try container.decodeIfPresent(String.self, forKey: "period")
        value = try container.decodeIfPresent(Double.self, forKey: "value")
        readingItemName = try container.decodeIfPresent(String.self, forKey: "readingItemName")
    }
}

