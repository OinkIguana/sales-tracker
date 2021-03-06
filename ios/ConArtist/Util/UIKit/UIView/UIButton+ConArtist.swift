//
//  UIButton+ConArtist.swift
//  ConArtist
//
//  Created by Cameron Eldridge on 2018-02-19.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import UIKit

extension UIButton {
    @discardableResult
    func conArtistStyle() -> Self {
        titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold).usingFeatures([.smallCaps])
        setTitleColor(.brand, for: .normal)
        setTitleColor(.brandVariant, for: .highlighted)
        setTitleColor(.brandVariant, for: .focused)
        setTitleColor(.textPlaceholder, for: .disabled)
        imageView?.tintColor = .brand
        return self
    }
}
