//
//  BaseClass.swift
//
//  Created by iMac Augusta on 10/16/19
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public struct MeUserData {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let vocThresholdWarningLevel = "vocThresholdWarningLevel"
    static let radonUnitTypeId = "radonUnitTypeId"
    static let companyLicenseNumber = "companyLicenseNumber"
    static let profileImage = "profileImage"
    static let isMobileNotificationFrequencyEnabled = "isMobileNotificationFrequencyEnabled"
    static let deviceId = "deviceId"
    static let isTextNotificationEnabled = "isTextNotificationEnabled"
    static let isSelectedRadonRiskInformationForReport = "isSelectedRadonRiskInformationForReport"
    static let temperatureRadonUnits = "temperatureRadonUnits"
    static let trialaccountstartdate = "trialaccountstartdate"
    static let genderId = "genderId"
    static let id = "id"
    static let humidityThresholdHighalertLevel = "humidityThresholdHighalertLevel"
    static let mitigationsystemtypeid = "mitigationsystemtypeid"
    static let address = "address"
    static let radonThresholdWarningLevel = "radonThresholdWarningLevel"
    static let isWeeklySummaryEmailEnabled = "isWeeklySummaryEmailEnabled"
    static let trialaccountenddate = "trialaccountenddate"
    static let warningColorCode = "warningColorCode"
    static let loginlevel = "loginlevel"
    static let nightlightColorCodeHex = "nightlightColorCodeHex"
    static let stateId = "stateId"
    static let hasAcceptedTerms = "hasAcceptedTerms"
    static let humidityThresholdLowWarningLevel = "humidityThresholdLowWarningLevel"
    static let airpressureRadonUnits = "airpressureRadonUnits"
    static let isSelectedOverallAverage = "isSelectedOverallAverage"
    static let isSelectedSignatureImageForReport = "isSelectedSignatureImageForReport"
    static let crmcreateddate = "crmcreateddate"
    static let companyName = "companyName"
    static let isSelectedUnderstandingRadonTestResults = "isSelectedUnderstandingRadonTestResults"
    static let co2ThresholdWarningLevel = "co2ThresholdWarningLevel"
    static let cityId = "cityId"
    static let enableNotifications = "enableNotifications"
    static let alertColorCode = "alertColorCode"
    static let lastName = "lastName"
    static let crmid = "crmid"
    static let hasAcceptedPrivacyPolicy = "hasAcceptedPrivacyPolicy"
    static let co2ThresholdAlertLevel = "co2ThresholdAlertLevel"
    static let isSummaryEmailEnabled = "isSummaryEmailEnabled"
    static let alertColorCodeHex = "alertColorCodeHex"
    static let companyZip = "companyZip"
    static let alignmentId = "alignmentId"
    static let sendNotificationOnSncApproval = "sendNotificationOnSncApproval"
    static let crmmodifieddate = "crmmodifieddate"
    static let airpressureThresholdHighWarningLevel = "airpressureThresholdHighWarningLevel"
    static let temperatureUnitTypeId = "temperatureUnitTypeId"
    static let airpressureThresholdHighalertLevel = "airpressureThresholdHighalertLevel"
    static let vocThresholdAlertLevel = "vocThresholdAlertLevel"
    static let isEmailNotificationEnabled = "isEmailNotificationEnabled"
    static let buildingtypeid = "buildingtypeid"
    static let companyPhonenumber = "companyPhonenumber"
    static let isSelectedLicenseNo = "isSelectedLicenseNo"
    static let temperatureThresholdLowalertLevel = "temperatureThresholdLowalertLevel"
    static let comments = "comments"
    static let isTrialUser = "isTrialUser"
    static let licenseTypeId = "licenseTypeId"
    static let airpressureThresholdLowWarningLevel = "airpressureThresholdLowWarningLevel"
    static let sendNotificationonDataSync = "sendNotificationonDataSync"
    static let stateNoticeId = "stateNoticeId"
    static let notificationEmail = "notificationEmail"
    static let companyAddress2 = "companyAddress2"
    static let zipcode = "zipcode"
    static let isMonthlySummaryEmailEnabled = "isMonthlySummaryEmailEnabled"
    static let isSelectedTestChart = "isSelectedTestChart"
    static let lastSummaryNotificationdate = "lastSummaryNotificationdate"
    static let timeZone = "timeZone"
    static let warningColorCodeHex = "warningColorCodeHex"
    static let companyAddress1 = "companyAddress1"
    static let temperatureThresholdHighWarningLevel = "temperatureThresholdHighWarningLevel"
    static let airpressureThresholdLowalertLevel = "airpressureThresholdLowalertLevel"
    static let mobileNo = "mobileNo"
    static let isDailySummaryEmailEnabled = "isDailySummaryEmailEnabled"
    static let isSelectedTestData = "isSelectedTestData"
    static let userTypeId = "userTypeId"
    static let nightlightColorCode = "nightlightColorCode"
    static let radonThresholdAlertLevel = "radonThresholdAlertLevel"
    static let firstName = "firstName"
    static let createdBy = "createdBy"
    static let okColorCodeHex = "okColorCodeHex"
    static let dob = "dob"
    static let okColorCode = "okColorCode"
    static let isSelectedEpaAverage = "isSelectedEpaAverage"
    static let humidityRadonUnits = "humidityRadonUnits"
    static let temperatureThresholdLowWarningLevel = "temperatureThresholdLowWarningLevel"
    static let roleId = "roleId"
    static let lastMothlyNotificationDate = "lastMothlyNotificationDate"
    static let temperatureThresholdHighalertLevel = "temperatureThresholdHighalertLevel"
    static let pressureUnitTypeId = "pressureUnitTypeId"
    static let companyCity = "companyCity"
    static let appLayout = "appLayout"
    static let appTheme = "appTheme"
    static let name = "name"
    static let email = "email"
    static let humidityThresholdLowalertLevel = "humidityThresholdLowalertLevel"
    static let crmAccountId = "crmAccountId"
    static let signatureImage = "signatureImage"
    static let actionLevel = "actionLevel"
    static let updatedBy = "updatedBy"
    static let headerImage = "headerImage"
    static let isDeleted = "isDeleted"
    static let humidityThresholdHighWarningLevel = "humidityThresholdHighWarningLevel"
    static let companyState = "companyState"
  }

  // MARK: Properties
  public var vocThresholdWarningLevel: Int?
  public var radonUnitTypeId: Int?
  public var companyLicenseNumber: String?
  public var profileImage: String?
  public var isMobileNotificationFrequencyEnabled: Bool? = false
  public var deviceId: Int?
  public var isTextNotificationEnabled: Bool? = false
  public var isSelectedRadonRiskInformationForReport: Bool? = false
  public var temperatureRadonUnits: Int?
  public var trialaccountstartdate: String?
  public var genderId: Int?
  public var id: Int?
  public var humidityThresholdHighalertLevel: Int?
  public var mitigationsystemtypeid: Int?
  public var address: String?
  public var radonThresholdWarningLevel: Int?
  public var isWeeklySummaryEmailEnabled: Bool? = false
  public var trialaccountenddate: String?
  public var warningColorCode: String?
  public var loginlevel: Int?
  public var nightlightColorCodeHex: String?
  public var stateId: Int?
  public var hasAcceptedTerms: Bool? = false
  public var humidityThresholdLowWarningLevel: Int?
  public var airpressureRadonUnits: Int?
  public var isSelectedOverallAverage: Bool? = false
  public var isSelectedSignatureImageForReport: Bool? = false
  public var crmcreateddate: String?
  public var companyName: String?
  public var isSelectedUnderstandingRadonTestResults: Bool? = false
  public var co2ThresholdWarningLevel: Int?
  public var cityId: Int?
  public var enableNotifications: Bool? = false
  public var alertColorCode: String?
  public var lastName: String?
  public var crmid: String?
  public var hasAcceptedPrivacyPolicy: Bool? = false
  public var co2ThresholdAlertLevel: Int?
  public var isSummaryEmailEnabled: Bool? = false
  public var alertColorCodeHex: String?
  public var companyZip: String?
  public var alignmentId: Int?
  public var sendNotificationOnSncApproval: Bool? = false
  public var crmmodifieddate: String?
  public var airpressureThresholdHighWarningLevel: Int?
  public var temperatureUnitTypeId: Int?
  public var airpressureThresholdHighalertLevel: Int?
  public var vocThresholdAlertLevel: Int?
  public var isEmailNotificationEnabled: Bool? = false
  public var buildingtypeid: Int?
  public var companyPhonenumber: String?
  public var isSelectedLicenseNo: Bool? = false
  public var temperatureThresholdLowalertLevel: Int?
  public var comments: String?
  public var isTrialUser: Bool? = false
  public var licenseTypeId: Int?
  public var airpressureThresholdLowWarningLevel: Int?
  public var sendNotificationonDataSync: Bool? = false
  public var stateNoticeId: Int?
  public var notificationEmail: String?
  public var companyAddress2: String?
  public var zipcode: String?
  public var isMonthlySummaryEmailEnabled: Bool? = false
  public var isSelectedTestChart: Bool? = false
  public var lastSummaryNotificationdate: String?
  public var timeZone: Int?
  public var warningColorCodeHex: String?
  public var companyAddress1: String?
  public var temperatureThresholdHighWarningLevel: Int?
  public var airpressureThresholdLowalertLevel: Int?
  public var mobileNo: String?
  public var isDailySummaryEmailEnabled: Bool? = false
  public var isSelectedTestData: Bool? = false
  public var userTypeId: Int?
  public var nightlightColorCode: String?
  public var radonThresholdAlertLevel: Int?
  public var firstName: String?
  public var createdBy: Int?
  public var okColorCodeHex: String?
  public var dob: String?
  public var okColorCode: String?
  public var isSelectedEpaAverage: Bool? = false
  public var humidityRadonUnits: Int?
  public var temperatureThresholdLowWarningLevel: Int?
  public var roleId: Int?
  public var lastMothlyNotificationDate: String?
  public var temperatureThresholdHighalertLevel: Int?
  public var pressureUnitTypeId: Int?
  public var companyCity: String?
  public var appLayout: Int?
  public var appTheme: Int?
  public var name: String?
  public var email: String?
  public var humidityThresholdLowalertLevel: Int?
  public var crmAccountId: String?
  public var signatureImage: String?
  public var actionLevel: Int?
  public var updatedBy: Int?
  public var headerImage: String?
  public var isDeleted: Bool? = false
  public var humidityThresholdHighWarningLevel: Int?
  public var companyState: String?

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
    vocThresholdWarningLevel = json[SerializationKeys.vocThresholdWarningLevel].int
    radonUnitTypeId = json[SerializationKeys.radonUnitTypeId].int
    companyLicenseNumber = json[SerializationKeys.companyLicenseNumber].string
    profileImage = json[SerializationKeys.profileImage].string
    isMobileNotificationFrequencyEnabled = json[SerializationKeys.isMobileNotificationFrequencyEnabled].boolValue
    deviceId = json[SerializationKeys.deviceId].int
    isTextNotificationEnabled = json[SerializationKeys.isTextNotificationEnabled].boolValue
    isSelectedRadonRiskInformationForReport = json[SerializationKeys.isSelectedRadonRiskInformationForReport].boolValue
    temperatureRadonUnits = json[SerializationKeys.temperatureRadonUnits].int
    trialaccountstartdate = json[SerializationKeys.trialaccountstartdate].string
    genderId = json[SerializationKeys.genderId].int
    id = json[SerializationKeys.id].int
    humidityThresholdHighalertLevel = json[SerializationKeys.humidityThresholdHighalertLevel].int
    mitigationsystemtypeid = json[SerializationKeys.mitigationsystemtypeid].int
    address = json[SerializationKeys.address].string
    radonThresholdWarningLevel = json[SerializationKeys.radonThresholdWarningLevel].int
    isWeeklySummaryEmailEnabled = json[SerializationKeys.isWeeklySummaryEmailEnabled].boolValue
    trialaccountenddate = json[SerializationKeys.trialaccountenddate].string
    warningColorCode = json[SerializationKeys.warningColorCode].string
    loginlevel = json[SerializationKeys.loginlevel].int
    nightlightColorCodeHex = json[SerializationKeys.nightlightColorCodeHex].string
    stateId = json[SerializationKeys.stateId].int
    hasAcceptedTerms = json[SerializationKeys.hasAcceptedTerms].boolValue
    humidityThresholdLowWarningLevel = json[SerializationKeys.humidityThresholdLowWarningLevel].int
    airpressureRadonUnits = json[SerializationKeys.airpressureRadonUnits].int
    isSelectedOverallAverage = json[SerializationKeys.isSelectedOverallAverage].boolValue
    isSelectedSignatureImageForReport = json[SerializationKeys.isSelectedSignatureImageForReport].boolValue
    crmcreateddate = json[SerializationKeys.crmcreateddate].string
    companyName = json[SerializationKeys.companyName].string
    isSelectedUnderstandingRadonTestResults = json[SerializationKeys.isSelectedUnderstandingRadonTestResults].boolValue
    co2ThresholdWarningLevel = json[SerializationKeys.co2ThresholdWarningLevel].int
    cityId = json[SerializationKeys.cityId].int
    enableNotifications = json[SerializationKeys.enableNotifications].boolValue
    alertColorCode = json[SerializationKeys.alertColorCode].string
    lastName = json[SerializationKeys.lastName].string
    crmid = json[SerializationKeys.crmid].string
    hasAcceptedPrivacyPolicy = json[SerializationKeys.hasAcceptedPrivacyPolicy].boolValue
    co2ThresholdAlertLevel = json[SerializationKeys.co2ThresholdAlertLevel].int
    isSummaryEmailEnabled = json[SerializationKeys.isSummaryEmailEnabled].boolValue
    alertColorCodeHex = json[SerializationKeys.alertColorCodeHex].string
    companyZip = json[SerializationKeys.companyZip].string
    alignmentId = json[SerializationKeys.alignmentId].int
    sendNotificationOnSncApproval = json[SerializationKeys.sendNotificationOnSncApproval].boolValue
    crmmodifieddate = json[SerializationKeys.crmmodifieddate].string
    airpressureThresholdHighWarningLevel = json[SerializationKeys.airpressureThresholdHighWarningLevel].int
    temperatureUnitTypeId = json[SerializationKeys.temperatureUnitTypeId].int
    airpressureThresholdHighalertLevel = json[SerializationKeys.airpressureThresholdHighalertLevel].int
    vocThresholdAlertLevel = json[SerializationKeys.vocThresholdAlertLevel].int
    isEmailNotificationEnabled = json[SerializationKeys.isEmailNotificationEnabled].boolValue
    buildingtypeid = json[SerializationKeys.buildingtypeid].int
    companyPhonenumber = json[SerializationKeys.companyPhonenumber].string
    isSelectedLicenseNo = json[SerializationKeys.isSelectedLicenseNo].boolValue
    temperatureThresholdLowalertLevel = json[SerializationKeys.temperatureThresholdLowalertLevel].int
    comments = json[SerializationKeys.comments].string
    isTrialUser = json[SerializationKeys.isTrialUser].boolValue
    licenseTypeId = json[SerializationKeys.licenseTypeId].int
    airpressureThresholdLowWarningLevel = json[SerializationKeys.airpressureThresholdLowWarningLevel].int
    sendNotificationonDataSync = json[SerializationKeys.sendNotificationonDataSync].boolValue
    stateNoticeId = json[SerializationKeys.stateNoticeId].int
    notificationEmail = json[SerializationKeys.notificationEmail].string
    companyAddress2 = json[SerializationKeys.companyAddress2].string
    zipcode = json[SerializationKeys.zipcode].string
    isMonthlySummaryEmailEnabled = json[SerializationKeys.isMonthlySummaryEmailEnabled].boolValue
    isSelectedTestChart = json[SerializationKeys.isSelectedTestChart].boolValue
    lastSummaryNotificationdate = json[SerializationKeys.lastSummaryNotificationdate].string
    timeZone = json[SerializationKeys.timeZone].int
    warningColorCodeHex = json[SerializationKeys.warningColorCodeHex].string
    companyAddress1 = json[SerializationKeys.companyAddress1].string
    temperatureThresholdHighWarningLevel = json[SerializationKeys.temperatureThresholdHighWarningLevel].int
    airpressureThresholdLowalertLevel = json[SerializationKeys.airpressureThresholdLowalertLevel].int
    mobileNo = json[SerializationKeys.mobileNo].string
    isDailySummaryEmailEnabled = json[SerializationKeys.isDailySummaryEmailEnabled].boolValue
    isSelectedTestData = json[SerializationKeys.isSelectedTestData].boolValue
    userTypeId = json[SerializationKeys.userTypeId].int
    nightlightColorCode = json[SerializationKeys.nightlightColorCode].string
    radonThresholdAlertLevel = json[SerializationKeys.radonThresholdAlertLevel].int
    firstName = json[SerializationKeys.firstName].string
    createdBy = json[SerializationKeys.createdBy].int
    okColorCodeHex = json[SerializationKeys.okColorCodeHex].string
    dob = json[SerializationKeys.dob].string
    okColorCode = json[SerializationKeys.okColorCode].string
    isSelectedEpaAverage = json[SerializationKeys.isSelectedEpaAverage].boolValue
    humidityRadonUnits = json[SerializationKeys.humidityRadonUnits].int
    temperatureThresholdLowWarningLevel = json[SerializationKeys.temperatureThresholdLowWarningLevel].int
    roleId = json[SerializationKeys.roleId].int
    lastMothlyNotificationDate = json[SerializationKeys.lastMothlyNotificationDate].string
    temperatureThresholdHighalertLevel = json[SerializationKeys.temperatureThresholdHighalertLevel].int
    pressureUnitTypeId = json[SerializationKeys.pressureUnitTypeId].int
    companyCity = json[SerializationKeys.companyCity].string
    appLayout = json[SerializationKeys.appLayout].int
    appTheme = json[SerializationKeys.appTheme].int
    name = json[SerializationKeys.name].string
    email = json[SerializationKeys.email].string
    humidityThresholdLowalertLevel = json[SerializationKeys.humidityThresholdLowalertLevel].int
    crmAccountId = json[SerializationKeys.crmAccountId].string
    signatureImage = json[SerializationKeys.signatureImage].string
    actionLevel = json[SerializationKeys.actionLevel].int
    updatedBy = json[SerializationKeys.updatedBy].int
    headerImage = json[SerializationKeys.headerImage].string
    isDeleted = json[SerializationKeys.isDeleted].boolValue
    humidityThresholdHighWarningLevel = json[SerializationKeys.humidityThresholdHighWarningLevel].int
    companyState = json[SerializationKeys.companyState].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = vocThresholdWarningLevel { dictionary[SerializationKeys.vocThresholdWarningLevel] = value }
    if let value = radonUnitTypeId { dictionary[SerializationKeys.radonUnitTypeId] = value }
    if let value = companyLicenseNumber { dictionary[SerializationKeys.companyLicenseNumber] = value }
    if let value = profileImage { dictionary[SerializationKeys.profileImage] = value }
    dictionary[SerializationKeys.isMobileNotificationFrequencyEnabled] = isMobileNotificationFrequencyEnabled
    if let value = deviceId { dictionary[SerializationKeys.deviceId] = value }
    dictionary[SerializationKeys.isTextNotificationEnabled] = isTextNotificationEnabled
    dictionary[SerializationKeys.isSelectedRadonRiskInformationForReport] = isSelectedRadonRiskInformationForReport
    if let value = temperatureRadonUnits { dictionary[SerializationKeys.temperatureRadonUnits] = value }
    if let value = trialaccountstartdate { dictionary[SerializationKeys.trialaccountstartdate] = value }
    if let value = genderId { dictionary[SerializationKeys.genderId] = value }
    if let value = id { dictionary[SerializationKeys.id] = value }
    if let value = humidityThresholdHighalertLevel { dictionary[SerializationKeys.humidityThresholdHighalertLevel] = value }
    if let value = mitigationsystemtypeid { dictionary[SerializationKeys.mitigationsystemtypeid] = value }
    if let value = address { dictionary[SerializationKeys.address] = value }
    if let value = radonThresholdWarningLevel { dictionary[SerializationKeys.radonThresholdWarningLevel] = value }
    dictionary[SerializationKeys.isWeeklySummaryEmailEnabled] = isWeeklySummaryEmailEnabled
    if let value = trialaccountenddate { dictionary[SerializationKeys.trialaccountenddate] = value }
    if let value = warningColorCode { dictionary[SerializationKeys.warningColorCode] = value }
    if let value = loginlevel { dictionary[SerializationKeys.loginlevel] = value }
    if let value = nightlightColorCodeHex { dictionary[SerializationKeys.nightlightColorCodeHex] = value }
    if let value = stateId { dictionary[SerializationKeys.stateId] = value }
    dictionary[SerializationKeys.hasAcceptedTerms] = hasAcceptedTerms
    if let value = humidityThresholdLowWarningLevel { dictionary[SerializationKeys.humidityThresholdLowWarningLevel] = value }
    if let value = airpressureRadonUnits { dictionary[SerializationKeys.airpressureRadonUnits] = value }
    dictionary[SerializationKeys.isSelectedOverallAverage] = isSelectedOverallAverage
    dictionary[SerializationKeys.isSelectedSignatureImageForReport] = isSelectedSignatureImageForReport
    if let value = crmcreateddate { dictionary[SerializationKeys.crmcreateddate] = value }
    if let value = companyName { dictionary[SerializationKeys.companyName] = value }
    dictionary[SerializationKeys.isSelectedUnderstandingRadonTestResults] = isSelectedUnderstandingRadonTestResults
    if let value = co2ThresholdWarningLevel { dictionary[SerializationKeys.co2ThresholdWarningLevel] = value }
    if let value = cityId { dictionary[SerializationKeys.cityId] = value }
    dictionary[SerializationKeys.enableNotifications] = enableNotifications
    if let value = alertColorCode { dictionary[SerializationKeys.alertColorCode] = value }
    if let value = lastName { dictionary[SerializationKeys.lastName] = value }
    if let value = crmid { dictionary[SerializationKeys.crmid] = value }
    dictionary[SerializationKeys.hasAcceptedPrivacyPolicy] = hasAcceptedPrivacyPolicy
    if let value = co2ThresholdAlertLevel { dictionary[SerializationKeys.co2ThresholdAlertLevel] = value }
    dictionary[SerializationKeys.isSummaryEmailEnabled] = isSummaryEmailEnabled
    if let value = alertColorCodeHex { dictionary[SerializationKeys.alertColorCodeHex] = value }
    if let value = companyZip { dictionary[SerializationKeys.companyZip] = value }
    if let value = alignmentId { dictionary[SerializationKeys.alignmentId] = value }
    dictionary[SerializationKeys.sendNotificationOnSncApproval] = sendNotificationOnSncApproval
    if let value = crmmodifieddate { dictionary[SerializationKeys.crmmodifieddate] = value }
    if let value = airpressureThresholdHighWarningLevel { dictionary[SerializationKeys.airpressureThresholdHighWarningLevel] = value }
    if let value = temperatureUnitTypeId { dictionary[SerializationKeys.temperatureUnitTypeId] = value }
    if let value = airpressureThresholdHighalertLevel { dictionary[SerializationKeys.airpressureThresholdHighalertLevel] = value }
    if let value = vocThresholdAlertLevel { dictionary[SerializationKeys.vocThresholdAlertLevel] = value }
    dictionary[SerializationKeys.isEmailNotificationEnabled] = isEmailNotificationEnabled
    if let value = buildingtypeid { dictionary[SerializationKeys.buildingtypeid] = value }
    if let value = companyPhonenumber { dictionary[SerializationKeys.companyPhonenumber] = value }
    dictionary[SerializationKeys.isSelectedLicenseNo] = isSelectedLicenseNo
    if let value = temperatureThresholdLowalertLevel { dictionary[SerializationKeys.temperatureThresholdLowalertLevel] = value }
    if let value = comments { dictionary[SerializationKeys.comments] = value }
    dictionary[SerializationKeys.isTrialUser] = isTrialUser
    if let value = licenseTypeId { dictionary[SerializationKeys.licenseTypeId] = value }
    if let value = airpressureThresholdLowWarningLevel { dictionary[SerializationKeys.airpressureThresholdLowWarningLevel] = value }
    dictionary[SerializationKeys.sendNotificationonDataSync] = sendNotificationonDataSync
    if let value = stateNoticeId { dictionary[SerializationKeys.stateNoticeId] = value }
    if let value = notificationEmail { dictionary[SerializationKeys.notificationEmail] = value }
    if let value = companyAddress2 { dictionary[SerializationKeys.companyAddress2] = value }
    if let value = zipcode { dictionary[SerializationKeys.zipcode] = value }
    dictionary[SerializationKeys.isMonthlySummaryEmailEnabled] = isMonthlySummaryEmailEnabled
    dictionary[SerializationKeys.isSelectedTestChart] = isSelectedTestChart
    if let value = lastSummaryNotificationdate { dictionary[SerializationKeys.lastSummaryNotificationdate] = value }
    if let value = timeZone { dictionary[SerializationKeys.timeZone] = value }
    if let value = warningColorCodeHex { dictionary[SerializationKeys.warningColorCodeHex] = value }
    if let value = companyAddress1 { dictionary[SerializationKeys.companyAddress1] = value }
    if let value = temperatureThresholdHighWarningLevel { dictionary[SerializationKeys.temperatureThresholdHighWarningLevel] = value }
    if let value = airpressureThresholdLowalertLevel { dictionary[SerializationKeys.airpressureThresholdLowalertLevel] = value }
    if let value = mobileNo { dictionary[SerializationKeys.mobileNo] = value }
    dictionary[SerializationKeys.isDailySummaryEmailEnabled] = isDailySummaryEmailEnabled
    dictionary[SerializationKeys.isSelectedTestData] = isSelectedTestData
    if let value = userTypeId { dictionary[SerializationKeys.userTypeId] = value }
    if let value = nightlightColorCode { dictionary[SerializationKeys.nightlightColorCode] = value }
    if let value = radonThresholdAlertLevel { dictionary[SerializationKeys.radonThresholdAlertLevel] = value }
    if let value = firstName { dictionary[SerializationKeys.firstName] = value }
    if let value = createdBy { dictionary[SerializationKeys.createdBy] = value }
    if let value = okColorCodeHex { dictionary[SerializationKeys.okColorCodeHex] = value }
    if let value = dob { dictionary[SerializationKeys.dob] = value }
    if let value = okColorCode { dictionary[SerializationKeys.okColorCode] = value }
    dictionary[SerializationKeys.isSelectedEpaAverage] = isSelectedEpaAverage
    if let value = humidityRadonUnits { dictionary[SerializationKeys.humidityRadonUnits] = value }
    if let value = temperatureThresholdLowWarningLevel { dictionary[SerializationKeys.temperatureThresholdLowWarningLevel] = value }
    if let value = roleId { dictionary[SerializationKeys.roleId] = value }
    if let value = lastMothlyNotificationDate { dictionary[SerializationKeys.lastMothlyNotificationDate] = value }
    if let value = temperatureThresholdHighalertLevel { dictionary[SerializationKeys.temperatureThresholdHighalertLevel] = value }
    if let value = pressureUnitTypeId { dictionary[SerializationKeys.pressureUnitTypeId] = value }
    if let value = companyCity { dictionary[SerializationKeys.companyCity] = value }
    if let value = appLayout { dictionary[SerializationKeys.appLayout] = value }
    if let value = appTheme { dictionary[SerializationKeys.appTheme] = value }
    if let value = name { dictionary[SerializationKeys.name] = value }
    if let value = email { dictionary[SerializationKeys.email] = value }
    if let value = humidityThresholdLowalertLevel { dictionary[SerializationKeys.humidityThresholdLowalertLevel] = value }
    if let value = crmAccountId { dictionary[SerializationKeys.crmAccountId] = value }
    if let value = signatureImage { dictionary[SerializationKeys.signatureImage] = value }
    if let value = actionLevel { dictionary[SerializationKeys.actionLevel] = value }
    if let value = updatedBy { dictionary[SerializationKeys.updatedBy] = value }
    if let value = headerImage { dictionary[SerializationKeys.headerImage] = value }
    dictionary[SerializationKeys.isDeleted] = isDeleted
    if let value = humidityThresholdHighWarningLevel { dictionary[SerializationKeys.humidityThresholdHighWarningLevel] = value }
    if let value = companyState { dictionary[SerializationKeys.companyState] = value }
    return dictionary
  }

}
