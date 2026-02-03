//
//  EviMailQueryRequest.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 03/02/26.
//


struct EviMailQueryRequest: Codable {
    let limit: Int
    let offset: Int?
    
    enum CodingKeys: String, CodingKey {
        case limit, offset
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(limit, forKey: .limit)
        if let offset = offset {
            try container.encode(offset, forKey: .offset)
        }
    }
}
