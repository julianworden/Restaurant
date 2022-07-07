//
//  Order.swift
//  Restaurant
//
//  Created by Julian Worden on 7/4/22.
//

import Foundation

struct Order: Codable {
    var menuItems: [MenuItem]

    init(menuItems: [MenuItem] = []) {
        self.menuItems = menuItems
    }
}
