//
//  DateHelper.swift
//  Post
//
//  Created by Nathan Andrus on 11/18/19.
//  Copyright © 2019 DevMountain. All rights reserved.
//

import Foundation

extension Date {
    
    /**
     Sets Formatting for out dates. Returns a String
     ## Important Notes ##
     1. This extends a Date; so it is usable on all Date objects
     2. Currently Set to medium date style
     3. Currently sets to medium time style
     */
    func stringValue() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}
