//
//  RecordTableViewCell.swift
//  ConArtist
//
//  Created by Cameron Eldridge on 2018-01-06.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import UIKit

class RecordTableViewCell: UITableViewCell {
    static let ID = "RecordCell"
    @IBOutlet weak var productsListLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var modifiedMarkView: UIView!

    func setup(for item: Record, with products: [Product]) {
        productsListLabel.text = item.products
            .reduce([:]) { (prev: [Int: Int], next) in
                // count up the products of each name
                var result = prev
                result[next] = (prev[next] ?? 0) + 1
                return result
            }.reduce("") { (prev: String, pair) in
                // turn the counts into a string
                let (productId, quantity) = pair
                guard let product = products.first(where: { $0.id == productId }) else {
                    // can just ignore invalid products since they shouldn't happen anyway
                    return prev
                }
                let result = "\(product.name)\(quantity > 1 ? " (\(quantity))" : "")"
                if prev == "" {
                    return result
                } else {
                    return "\(prev), \(result)"
                }
        }
        priceLabel.font = priceLabel.font.usingFeatures([.tabularFigures])
        priceLabel.text = item.price.toString()
        timeLabel.text = item.time.toString("E h:mm")
        modifiedMarkView.backgroundColor = item.id == nil ? ConArtist.Color.BrandVariant : ConArtist.Color.BackgroundVariant
    }
}
