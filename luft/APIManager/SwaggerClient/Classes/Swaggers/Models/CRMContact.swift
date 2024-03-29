//
// CRMContact.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class CRMContact: Codable {

    public var id: String?
    public var firstName: String?
    public var lastName: String?
    public var address: CRMAddress?
    public var email: String?
    public var phone: String?
    public var account: CRMAccount?
    public var createdDate: String?
    public var systemModstamp: String?


    
    public init(id: String?, firstName: String?, lastName: String?, address: CRMAddress?, email: String?, phone: String?, account: CRMAccount?, createdDate: String?, systemModstamp: String?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.email = email
        self.phone = phone
        self.account = account
        self.createdDate = createdDate
        self.systemModstamp = systemModstamp
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(firstName, forKey: "firstName")
        try container.encodeIfPresent(lastName, forKey: "lastName")
        try container.encodeIfPresent(address, forKey: "address")
        try container.encodeIfPresent(email, forKey: "email")
        try container.encodeIfPresent(phone, forKey: "phone")
        try container.encodeIfPresent(account, forKey: "account")
        try container.encodeIfPresent(createdDate, forKey: "createdDate")
        try container.encodeIfPresent(systemModstamp, forKey: "systemModstamp")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        id = try container.decodeIfPresent(String.self, forKey: "id")
        firstName = try container.decodeIfPresent(String.self, forKey: "firstName")
        lastName = try container.decodeIfPresent(String.self, forKey: "lastName")
        address = try container.decodeIfPresent(CRMAddress.self, forKey: "address")
        email = try container.decodeIfPresent(String.self, forKey: "email")
        phone = try container.decodeIfPresent(String.self, forKey: "phone")
        account = try container.decodeIfPresent(CRMAccount.self, forKey: "account")
        createdDate = try container.decodeIfPresent(String.self, forKey: "createdDate")
        systemModstamp = try container.decodeIfPresent(String.self, forKey: "systemModstamp")
    }
}

