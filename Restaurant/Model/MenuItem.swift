//
//  MenuItem.swift
//  Restaurant
//
//  Created by Julian Worden on 7/4/22.
//

import Foundation

struct MenuItem: Codable {
    let price: Double
    let id: Int
    let imageUrl: URL
    let name: String
    let category: String
    let details: String

    enum CodingKeys: String, CodingKey {
        case price
        case id
        case imageUrl = "image_url"
        case name
        case category
        case details = "description"
    }
}
