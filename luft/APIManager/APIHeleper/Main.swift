//
//  Main.swift
//
//  Created by iMac Augusta on 12/17/19
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Main {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let humidity = "humidity"
    static let tempMin = "temp_min"
    static let tempMax = "temp_max"
    static let feelsLike = "feels_like"
    static let temp = "temp"
    static let pressure = "pressure"
  }

  // MARK: Properties
  public var humidity: Int?
  public var tempMin: Float?
  public var tempMax: Float?
  public var feelsLike: Float?
  public var temp: Float?
  public var pressure: Int?

  // MARK: SwiftyJSON Initializers
  /// Initiates the instance based on the object.
  ///
  /// - parameter object: The object of either Dictionary or Array kind that was passed.
  /// - returns: An initialized instance of the class.
  public init(object: Any) {
    self.init(json: JSON(object))
  }

  /// Initiates the instance based on the JSON that was passed.
  ///
  /// - parameter json: JSON object from SwiftyJSON.
  public init(json: JSON) {
    humidity = json[SerializationKeys.humidity].int
    tempMin = json[SerializationKeys.tempMin].float
    tempMax = json[SerializationKeys.tempMax].float
    feelsLike = json[SerializationKeys.feelsLike].float
    temp = json[SerializationKeys.temp].float
    pressure = json[SerializationKeys.pressure].int
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = humidity { dictionary[SerializationKeys.humidity] = value }
    if let value = tempMin { dictionary[SerializationKeys.tempMin] = value }
    if let value = tempMax { dictionary[SerializationKeys.tempMax] = value }
    if let value = feelsLike { dictionary[SerializationKeys.feelsLike] = value }
    if let value = temp { dictionary[SerializationKeys.temp] = value }
    if let value = pressure { dictionary[SerializationKeys.pressure] = value }
    return dictionary
  }

}
