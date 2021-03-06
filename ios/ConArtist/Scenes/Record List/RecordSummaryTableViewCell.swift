//
//  RecordSummaryTableViewCell.swift
//  ConArtist
//
//  Created by Cameron Eldridge on 2018-03-08.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import UIKit

class RecordSummaryTableViewCell: ConArtistTableViewCell {
    static let ID = "RecordSummaryCell"

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    func setup(for price: Money, and count: Int) {
        priceLabel.text = price.toString()
        priceLabel.font = priceLabel.font.usingFeatures([.tabularFigures])
        countLabel.text = "(\(count))"
        titleLabel.text = "Sales"¡
    }
}
