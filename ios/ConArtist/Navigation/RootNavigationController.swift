//
//  RootNavigationController.swift
//  ConArtist
//
//  Created by Cameron Eldridge on 2018-02-02.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import UIKit
import RxSwift

class RootNavigationController: RxNavigationController {
    static let ID = "Root"

    override func viewDidLoad() {
        views = ConArtist.model.page.asObservable()
        super.viewDidLoad()
        SplashScreenViewController.show()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension RootNavigationController {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewCount > 3
    }
}
