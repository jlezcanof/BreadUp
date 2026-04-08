//
//  BreadUPSchemaV2.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano on 8/4/26.
//
import Foundation
import SwiftData

enum BreadUpSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        Schema.Version(2, 0, 0)
    }

    static var models: [any PersistentModel.Type] {
        []
    }
}
