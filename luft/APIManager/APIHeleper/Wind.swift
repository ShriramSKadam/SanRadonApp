//
//  Wind.swift
//
//  Created by iMac Augusta on 12/17/19
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Wind {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let speed = "speed"
    static let deg = "deg"
  }

  // MARK: Properties
  public var speed: Float?
  public var deg: Int?

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
    speed = json[SerializationKeys.speed].float
    deg = json[SerializationKeys.deg].int
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = speed { dictionary[SerializationKeys.speed] = value }
    if let value = deg { dictionary[SerializationKeys.deg] = value }
    return dictionary
  }

}
