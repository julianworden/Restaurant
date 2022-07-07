//
//  MenuItemTableViewCell.swift
//  Restaurant
//
//  Created by Julian Worden on 7/7/22.
//

import UIKit

class MenuItemTableViewCell: UITableViewCell {
    var itemName: String? {
        didSet {
            if oldValue != itemName {
                setNeedsUpdateConfiguration()
            }
        }
    }
    var price: Double? {
        didSet {
            if oldValue != price {
                setNeedsUpdateConfiguration()
            }
        }
    }
    var image: UIImage? {
        didSet {
            if oldValue != image {
                setNeedsUpdateConfiguration()
            }
        }
    }

    override func updateConfiguration(using state: UICellConfigurationState) {
        var content = defaultContentConfiguration().updated(for: state)
        content.text = itemName
        content.secondaryText = price?.formatted(.currency(code: Locale.current.currencyCode ?? "usd"))
        content.prefersSideBySideTextAndSecondaryText = true

        if let image = image {
            content.image = image
        } else {
            content.image = UIImage(systemName: "photo.on.rectangle")
        }
        self.contentConfiguration = content
    }
}
