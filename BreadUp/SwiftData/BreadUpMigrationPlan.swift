//
//  BreadUpMigrationPlan.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano on 8/4/26.
//

import Foundation
import SwiftData

enum BreadUpMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [BreadUpSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        [
//            .lightweight(fromVersion: BreadUpSchemaV1.self, toVersion: BreadUpSchemaV2.self)
        ]
    }
}


typealias BreadUPIngredients         = BreadUpSchemaV1.Ingredients
