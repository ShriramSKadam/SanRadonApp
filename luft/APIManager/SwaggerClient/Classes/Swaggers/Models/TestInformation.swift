//
// TestInformation.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class TestInformation: Codable {

    public var motionErrors: Int?
    public var pressureReadings: Double?
    public var radonReadings: Double?
    public var relativeHumidityReadings: Int?
    public var temperatureReadings: Double?
    public var timeStamp: String?
    public var vocReadings: Double?
    public var cO2Readings: Double?
    public var radonUnit: Int?


    
    public init(motionErrors: Int?, pressureReadings: Double?, radonReadings: Double?, relativeHumidityReadings: Int?, temperatureReadings: Double?, timeStamp: String?, vocReadings: Double?, cO2Readings: Double?, radonUnit: Int?) {
        self.motionErrors = motionErrors
        self.pressureReadings = pressureReadings
        self.radonReadings = radonReadings
        self.relativeHumidityReadings = relativeHumidityReadings
        self.temperatureReadings = temperatureReadings
        self.timeStamp = timeStamp
        self.vocReadings = vocReadings
        self.cO2Readings = cO2Readings
        self.radonUnit = radonUnit
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(motionErrors, forKey: "motionErrors")
        try container.encodeIfPresent(pressureReadings, forKey: "pressureReadings")
        try container.encodeIfPresent(radonReadings, forKey: "radonReadings")
        try container.encodeIfPresent(relativeHumidityReadings, forKey: "relativeHumidityReadings")
        try container.encodeIfPresent(temperatureReadings, forKey: "temperatureReadings")
        try container.encodeIfPresent(timeStamp, forKey: "timeStamp")
        try container.encodeIfPresent(vocReadings, forKey: "vocReadings")
        try container.encodeIfPresent(cO2Readings, forKey: "cO2Readings")
        try container.encodeIfPresent(radonUnit, forKey: "radonUnit")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        motionErrors = try container.decodeIfPresent(Int.self, forKey: "motionErrors")
        pressureReadings = try container.decodeIfPresent(Double.self, forKey: "pressureReadings")
        radonReadings = try container.decodeIfPresent(Double.self, forKey: "radonReadings")
        relativeHumidityReadings = try container.decodeIfPresent(Int.self, forKey: "relativeHumidityReadings")
        temperatureReadings = try container.decodeIfPresent(Double.self, forKey: "temperatureReadings")
        timeStamp = try container.decodeIfPresent(String.self, forKey: "timeStamp")
        vocReadings = try container.decodeIfPresent(Double.self, forKey: "vocReadings")
        cO2Readings = try container.decodeIfPresent(Double.self, forKey: "cO2Readings")
        radonUnit = try container.decodeIfPresent(Int.self, forKey: "radonUnit")
    }
}

