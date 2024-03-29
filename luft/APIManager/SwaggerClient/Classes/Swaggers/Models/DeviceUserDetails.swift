//
// DeviceUserDetails.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class DeviceUserDetails: Codable {

    public var deviceid: Int64?
    public var userid: Int64?
    public var email: String?
    public var companyname: String?
    public var firstname: String?
    public var lastname: String?
    public var licensetypeid: Int64?
    public var licensetype: String?
    public var address: String?
    public var cityid: Int64?
    public var stateid: Int64?
    public var zipcode: String?
    public var genderid: Int?
    public var dateofbirth: String?
    public var buildingtypeid: Int?
    public var mitigationsystemtypeid: Int?


    
    public init(deviceid: Int64?, userid: Int64?, email: String?, companyname: String?, firstname: String?, lastname: String?, licensetypeid: Int64?, licensetype: String?, address: String?, cityid: Int64?, stateid: Int64?, zipcode: String?, genderid: Int?, dateofbirth: String?, buildingtypeid: Int?, mitigationsystemtypeid: Int?) {
        self.deviceid = deviceid
        self.userid = userid
        self.email = email
        self.companyname = companyname
        self.firstname = firstname
        self.lastname = lastname
        self.licensetypeid = licensetypeid
        self.licensetype = licensetype
        self.address = address
        self.cityid = cityid
        self.stateid = stateid
        self.zipcode = zipcode
        self.genderid = genderid
        self.dateofbirth = dateofbirth
        self.buildingtypeid = buildingtypeid
        self.mitigationsystemtypeid = mitigationsystemtypeid
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(deviceid, forKey: "deviceid")
        try container.encodeIfPresent(userid, forKey: "userid")
        try container.encodeIfPresent(email, forKey: "email")
        try container.encodeIfPresent(companyname, forKey: "companyname")
        try container.encodeIfPresent(firstname, forKey: "firstname")
        try container.encodeIfPresent(lastname, forKey: "lastname")
        try container.encodeIfPresent(licensetypeid, forKey: "licensetypeid")
        try container.encodeIfPresent(licensetype, forKey: "licensetype")
        try container.encodeIfPresent(address, forKey: "address")
        try container.encodeIfPresent(cityid, forKey: "cityid")
        try container.encodeIfPresent(stateid, forKey: "stateid")
        try container.encodeIfPresent(zipcode, forKey: "zipcode")
        try container.encodeIfPresent(genderid, forKey: "genderid")
        try container.encodeIfPresent(dateofbirth, forKey: "dateofbirth")
        try container.encodeIfPresent(buildingtypeid, forKey: "buildingtypeid")
        try container.encodeIfPresent(mitigationsystemtypeid, forKey: "mitigationsystemtypeid")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        deviceid = try container.decodeIfPresent(Int64.self, forKey: "deviceid")
        userid = try container.decodeIfPresent(Int64.self, forKey: "userid")
        email = try container.decodeIfPresent(String.self, forKey: "email")
        companyname = try container.decodeIfPresent(String.self, forKey: "companyname")
        firstname = try container.decodeIfPresent(String.self, forKey: "firstname")
        lastname = try container.decodeIfPresent(String.self, forKey: "lastname")
        licensetypeid = try container.decodeIfPresent(Int64.self, forKey: "licensetypeid")
        licensetype = try container.decodeIfPresent(String.self, forKey: "licensetype")
        address = try container.decodeIfPresent(String.self, forKey: "address")
        cityid = try container.decodeIfPresent(Int64.self, forKey: "cityid")
        stateid = try container.decodeIfPresent(Int64.self, forKey: "stateid")
        zipcode = try container.decodeIfPresent(String.self, forKey: "zipcode")
        genderid = try container.decodeIfPresent(Int.self, forKey: "genderid")
        dateofbirth = try container.decodeIfPresent(String.self, forKey: "dateofbirth")
        buildingtypeid = try container.decodeIfPresent(Int.self, forKey: "buildingtypeid")
        mitigationsystemtypeid = try container.decodeIfPresent(Int.self, forKey: "mitigationsystemtypeid")
    }
}

