//
//  Sys.swift
//
//  Created by iMac Augusta on 12/17/19
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Sys {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let sunset = "sunset"
    static let sunrise = "sunrise"
    static let id = "id"
    static let type = "type"
    static let country = "country"
  }

  // MARK: Properties
  public var sunset: Int?
  public var sunrise: Int?
  public var id: Int?
  public var type: Int?
  public var country: String?

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
    sunset = json[SerializationKeys.sunset].int
    sunrise = json[SerializationKeys.sunrise].int
    id = json[SerializationKeys.id].int
    type = json[SerializationKeys.type].int
    country = json[SerializationKeys.country].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = sunset { dictionary[SerializationKeys.sunset] = value }
    if let value = sunrise { dictionary[SerializationKeys.sunrise] = value }
    if let value = id { dictionary[SerializationKeys.id] = value }
    if let value = type { dictionary[SerializationKeys.type] = value }
    if let value = country { dictionary[SerializationKeys.country] = value }
    return dictionary
  }

}
