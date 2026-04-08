//
//  FlourType.swift
//  BreadUp
//

import Foundation
import SwiftData

enum FlourType: String, CaseIterable, Identifiable {
    case wheat = "Harina de trigo"
    case wholeWheat = "Harina de trigo integral"
    case rye = "Harina de Centeno"
    case spelt = "Harina de espelta"
    case corn = "Harina de maíz"

    var id: Self { self }
}

extension FlourType {
    var toSchemaType: BreadUpSchemaV1.TypeFlour {
        switch self {
        case .wheat:      .wheat
        case .wholeWheat: .wholewheat
        case .rye:        .rye
        case .spelt:      .spelt
        case .corn:       .corn
        }
    }
}
