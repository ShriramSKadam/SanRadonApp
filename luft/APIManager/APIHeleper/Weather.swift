//
//  Weather.swift
//
//  Created by iMac Augusta on 12/17/19
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Weather {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let main = "main"
    static let icon = "icon"
    static let descriptionValue = "description"
    static let id = "id"
  }

  // MARK: Properties
  public var main: String?
  public var icon: String?
  public var descriptionValue: String?
  public var id: Int?

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
    main = json[SerializationKeys.main].string
    icon = json[SerializationKeys.icon].string
    descriptionValue = json[SerializationKeys.descriptionValue].string
    id = json[SerializationKeys.id].int
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = main { dictionary[SerializationKeys.main] = value }
    if let value = icon { dictionary[SerializationKeys.icon] = value }
    if let value = descriptionValue { dictionary[SerializationKeys.descriptionValue] = value }
    if let value = id { dictionary[SerializationKeys.id] = value }
    return dictionary
  }

}
