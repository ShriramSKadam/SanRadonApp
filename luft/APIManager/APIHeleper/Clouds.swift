//
//  Clouds.swift
//
//  Created by iMac Augusta on 12/17/19
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Clouds {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let all = "all"
  }

  // MARK: Properties
  public var all: Int?

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
    all = json[SerializationKeys.all].int
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = all { dictionary[SerializationKeys.all] = value }
    return dictionary
  }

}
