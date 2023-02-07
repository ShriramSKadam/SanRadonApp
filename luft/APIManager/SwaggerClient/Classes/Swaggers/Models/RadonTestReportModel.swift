//
// RadonTestReportModel.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class RadonTestReportModel: Codable {

    public var testLocation: TestLocationModel?
    public var testFor: TestForModel?
    public var inspectedBy: InspectedByModel?
    public var imageData: String?
    public var testMonitoringInformation: TestMonitoringInformationModel?
    public var testSiteCondition: TestSiteConditionModel?
    public var isSelectTestSiteCondition: Bool?
    public var isSelectOverallAvg: Bool?
    public var isSelectEPAAverage: Bool?
    public var testSummary: TestSummaryModel?
    public var testDetails: TestDetailsModel?
    public var isSelectTestResult: Bool?
    public var testResult: String?
    public var comments: String?
    public var licenseTypeId: Int?
    public var signatureUrl: String?
    public var snName: String?
    public var snReviewer: String?
    public var snAddress: String?
    public var headerImageAlign: String?
    public var testReport: String?
    public var version: String?
    public var testNumber: String?
    public var headerImage: String?
    public var inspectionTestResult: String?


    
    public init(testLocation: TestLocationModel?, testFor: TestForModel?, inspectedBy: InspectedByModel?, imageData: String?, testMonitoringInformation: TestMonitoringInformationModel?, testSiteCondition: TestSiteConditionModel?, isSelectTestSiteCondition: Bool?, isSelectOverallAvg: Bool?, isSelectEPAAverage: Bool?, testSummary: TestSummaryModel?, testDetails: TestDetailsModel?, isSelectTestResult: Bool?, testResult: String?, comments: String?, licenseTypeId: Int?, signatureUrl: String?, snName: String?, snReviewer: String?, snAddress: String?, headerImageAlign: String?, testReport: String?, version: String?, testNumber: String?, headerImage: String?, inspectionTestResult: String?) {
        self.testLocation = testLocation
        self.testFor = testFor
        self.inspectedBy = inspectedBy
        self.imageData = imageData
        self.testMonitoringInformation = testMonitoringInformation
        self.testSiteCondition = testSiteCondition
        self.isSelectTestSiteCondition = isSelectTestSiteCondition
        self.isSelectOverallAvg = isSelectOverallAvg
        self.isSelectEPAAverage = isSelectEPAAverage
        self.testSummary = testSummary
        self.testDetails = testDetails
        self.isSelectTestResult = isSelectTestResult
        self.testResult = testResult
        self.comments = comments
        self.licenseTypeId = licenseTypeId
        self.signatureUrl = signatureUrl
        self.snName = snName
        self.snReviewer = snReviewer
        self.snAddress = snAddress
        self.headerImageAlign = headerImageAlign
        self.testReport = testReport
        self.version = version
        self.testNumber = testNumber
        self.headerImage = headerImage
        self.inspectionTestResult = inspectionTestResult
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(testLocation, forKey: "testLocation")
        try container.encodeIfPresent(testFor, forKey: "testFor")
        try container.encodeIfPresent(inspectedBy, forKey: "inspectedBy")
        try container.encodeIfPresent(imageData, forKey: "imageData")
        try container.encodeIfPresent(testMonitoringInformation, forKey: "testMonitoringInformation")
        try container.encodeIfPresent(testSiteCondition, forKey: "testSiteCondition")
        try container.encodeIfPresent(isSelectTestSiteCondition, forKey: "isSelectTestSiteCondition")
        try container.encodeIfPresent(isSelectOverallAvg, forKey: "isSelectOverallAvg")
        try container.encodeIfPresent(isSelectEPAAverage, forKey: "isSelectEPAAverage")
        try container.encodeIfPresent(testSummary, forKey: "testSummary")
        try container.encodeIfPresent(testDetails, forKey: "testDetails")
        try container.encodeIfPresent(isSelectTestResult, forKey: "isSelectTestResult")
        try container.encodeIfPresent(testResult, forKey: "testResult")
        try container.encodeIfPresent(comments, forKey: "comments")
        try container.encodeIfPresent(licenseTypeId, forKey: "licenseTypeId")
        try container.encodeIfPresent(signatureUrl, forKey: "signatureUrl")
        try container.encodeIfPresent(snName, forKey: "snName")
        try container.encodeIfPresent(snReviewer, forKey: "snReviewer")
        try container.encodeIfPresent(snAddress, forKey: "snAddress")
        try container.encodeIfPresent(headerImageAlign, forKey: "headerImageAlign")
        try container.encodeIfPresent(testReport, forKey: "testReport")
        try container.encodeIfPresent(version, forKey: "version")
        try container.encodeIfPresent(testNumber, forKey: "testNumber")
        try container.encodeIfPresent(headerImage, forKey: "headerImage")
        try container.encodeIfPresent(inspectionTestResult, forKey: "inspectionTestResult")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        testLocation = try container.decodeIfPresent(TestLocationModel.self, forKey: "testLocation")
        testFor = try container.decodeIfPresent(TestForModel.self, forKey: "testFor")
        inspectedBy = try container.decodeIfPresent(InspectedByModel.self, forKey: "inspectedBy")
        imageData = try container.decodeIfPresent(String.self, forKey: "imageData")
        testMonitoringInformation = try container.decodeIfPresent(TestMonitoringInformationModel.self, forKey: "testMonitoringInformation")
        testSiteCondition = try container.decodeIfPresent(TestSiteConditionModel.self, forKey: "testSiteCondition")
        isSelectTestSiteCondition = try container.decodeIfPresent(Bool.self, forKey: "isSelectTestSiteCondition")
        isSelectOverallAvg = try container.decodeIfPresent(Bool.self, forKey: "isSelectOverallAvg")
        isSelectEPAAverage = try container.decodeIfPresent(Bool.self, forKey: "isSelectEPAAverage")
        testSummary = try container.decodeIfPresent(TestSummaryModel.self, forKey: "testSummary")
        testDetails = try container.decodeIfPresent(TestDetailsModel.self, forKey: "testDetails")
        isSelectTestResult = try container.decodeIfPresent(Bool.self, forKey: "isSelectTestResult")
        testResult = try container.decodeIfPresent(String.self, forKey: "testResult")
        comments = try container.decodeIfPresent(String.self, forKey: "comments")
        licenseTypeId = try container.decodeIfPresent(Int.self, forKey: "licenseTypeId")
        signatureUrl = try container.decodeIfPresent(String.self, forKey: "signatureUrl")
        snName = try container.decodeIfPresent(String.self, forKey: "snName")
        snReviewer = try container.decodeIfPresent(String.self, forKey: "snReviewer")
        snAddress = try container.decodeIfPresent(String.self, forKey: "snAddress")
        headerImageAlign = try container.decodeIfPresent(String.self, forKey: "headerImageAlign")
        testReport = try container.decodeIfPresent(String.self, forKey: "testReport")
        version = try container.decodeIfPresent(String.self, forKey: "version")
        testNumber = try container.decodeIfPresent(String.self, forKey: "testNumber")
        headerImage = try container.decodeIfPresent(String.self, forKey: "headerImage")
        inspectionTestResult = try container.decodeIfPresent(String.self, forKey: "inspectionTestResult")
    }
}
