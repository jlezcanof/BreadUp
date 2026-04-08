//
//  Item.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano on 25/3/26.
//

import Foundation
import SwiftData

@available(*, deprecated, renamed: "notexists", message: "delete")
@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
