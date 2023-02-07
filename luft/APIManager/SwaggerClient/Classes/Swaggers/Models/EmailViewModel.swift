//
// EmailViewModel.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** Represents ApproveInspectionModel */

public class EmailViewModel: Codable {

    /** Gets or sets the email. */
    public var email: String
    /** Gets or sets the subject. */
    public var subject: String
    /** Gets or sets the body. */
    public var body: String
    /** Gets or sets the attachments. */
    public var attachments: Data?
    /** Gets or sets the name of the file. */
    public var fileName: String?
    /**  */
    public var mailType: Int?
    public var inspectionid: Int64?


    
    public init(email: String, subject: String, body: String, attachments: Data?, fileName: String?, mailType: Int?, inspectionid: Int64?) {
        self.email = email
        self.subject = subject
        self.body = body
        self.attachments = attachments
        self.fileName = fileName
        self.mailType = mailType
        self.inspectionid = inspectionid
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encode(email, forKey: "email")
        try container.encode(subject, forKey: "subject")
        try container.encode(body, forKey: "body")
        try container.encodeIfPresent(attachments, forKey: "attachments")
        try container.encodeIfPresent(fileName, forKey: "fileName")
        try container.encodeIfPresent(mailType, forKey: "mailType")
        try container.encodeIfPresent(inspectionid, forKey: "inspectionid")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        email = try container.decode(String.self, forKey: "email")
        subject = try container.decode(String.self, forKey: "subject")
        body = try container.decode(String.self, forKey: "body")
        attachments = try container.decodeIfPresent(Data.self, forKey: "attachments")
        fileName = try container.decodeIfPresent(String.self, forKey: "fileName")
        mailType = try container.decodeIfPresent(Int.self, forKey: "mailType")
        inspectionid = try container.decodeIfPresent(Int64.self, forKey: "inspectionid")
    }
}

