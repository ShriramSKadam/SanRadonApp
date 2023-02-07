//
// TestDataTableModel.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public class TestDataTableModel: Codable {

    public var dataTableUnit: DataTableUnitModel?
    public var dataTables: [DataTableModel]?


    
    public init(dataTableUnit: DataTableUnitModel?, dataTables: [DataTableModel]?) {
        self.dataTableUnit = dataTableUnit
        self.dataTables = dataTables
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(dataTableUnit, forKey: "dataTableUnit")
        try container.encodeIfPresent(dataTables, forKey: "dataTables")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        dataTableUnit = try container.decodeIfPresent(DataTableUnitModel.self, forKey: "dataTableUnit")
        dataTables = try container.decodeIfPresent([DataTableModel].self, forKey: "dataTables")
    }
}
