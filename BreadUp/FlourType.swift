//
//  FlourType.swift
//  BreadUp
//

import Foundation

enum FlourType: String, CaseIterable, Identifiable {
    case wheat = "Harina de trigo"
    case wholeWheat = "Harina de trigo integral"
    case rye = "Harina de Centeno"
    case spelt = "Harina de espelta"
    case corn = "Harina de maíz"

    var id: Self { self }
}
