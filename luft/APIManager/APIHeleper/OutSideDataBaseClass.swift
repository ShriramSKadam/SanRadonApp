//
//  BaseClass.swift
//
//  Created by iMac Augusta on 12/17/19
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public struct OutSideDataBaseClass {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let main = "main"
    static let name = "name"
    static let coord = "coord"
    static let weather = "weather"
    static let dt = "dt"
    static let visibility = "visibility"
    static let rain = "rain"
    static let id = "id"
    static let clouds = "clouds"
    static let timezone = "timezone"
    static let base = "base"
    static let sys = "sys"
    static let cod = "cod"
    static let wind = "wind"
  }

  // MARK: Properties
  public var main: Main?
  public var name: String?
  public var coord: Coord?
  public var weather: [Weather]?
  public var dt: Int?
  public var visibility: Int?
  public var id: Int?
  public var clouds: Clouds?
  public var timezone: Int?
  public var base: String?
  public var sys: Sys?
  public var cod: Int?
  public var wind: Wind?

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
    main = Main(json: json[SerializationKeys.main])
    name = json[SerializationKeys.name].string
    coord = Coord(json: json[SerializationKeys.coord])
    if let items = json[SerializationKeys.weather].array { weather = items.map { Weather(json: $0) } }
    dt = json[SerializationKeys.dt].int
    visibility = json[SerializationKeys.visibility].int
    id = json[SerializationKeys.id].int
    clouds = Clouds(json: json[SerializationKeys.clouds])
    timezone = json[SerializationKeys.timezone].int
    base = json[SerializationKeys.base].string
    sys = Sys(json: json[SerializationKeys.sys])
    cod = json[SerializationKeys.cod].int
    wind = Wind(json: json[SerializationKeys.wind])
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = main { dictionary[SerializationKeys.main] = value.dictionaryRepresentation() }
    if let value = name { dictionary[SerializationKeys.name] = value }
    if let value = coord { dictionary[SerializationKeys.coord] = value.dictionaryRepresentation() }
    if let value = weather { dictionary[SerializationKeys.weather] = value.map { $0.dictionaryRepresentation() } }
    if let value = dt { dictionary[SerializationKeys.dt] = value }
    if let value = visibility { dictionary[SerializationKeys.visibility] = value }
    if let value = id { dictionary[SerializationKeys.id] = value }
    if let value = clouds { dictionary[SerializationKeys.clouds] = value.dictionaryRepresentation() }
    if let value = timezone { dictionary[SerializationKeys.timezone] = value }
    if let value = base { dictionary[SerializationKeys.base] = value }
    if let value = sys { dictionary[SerializationKeys.sys] = value.dictionaryRepresentation() }
    if let value = cod { dictionary[SerializationKeys.cod] = value }
    if let value = wind { dictionary[SerializationKeys.wind] = value.dictionaryRepresentation() }
    return dictionary
  }

}
