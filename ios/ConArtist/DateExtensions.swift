//
//  DateExtensions.swift
//  ConArtist
//
//  Created by Cameron Eldridge on 2017-12-21.
//  Copyright © 2017 Cameron Eldridge. All rights reserved.
//

import Foundation
import SwiftMoment

extension String {
    func toDate() -> Date? {
        return moment(self)?.date
    }
}

extension Date {
    static func today() -> Date {
        // TODO: can this be done with moment?
        let components = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        return Calendar.current.date(from: components)!
    }
    
    func toString(_ format: String) -> String {
        return moment(self).format(format)
    }
}