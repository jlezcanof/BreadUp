//
//  BreadUpApp.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano on 25/3/26.
//

import SwiftUI
import SwiftData

@main
struct BreadUpApp: App {
    
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: BreadUpIngredients.self, migrationPlan: BreadUpMigrationPlan.self)
        } catch {
            fatalError("No se puede crear el ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
