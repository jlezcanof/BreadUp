//
//  BreadUpApp.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano on 25/3/26.
//

import SwiftUI
import SwiftData
import FoundationModels

@main
struct BreadUpApp: App {
    
    let container: ModelContainer
    
    init() {
        do {
            // container = try ModelContainer(for: BreadUpIngredients.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
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
//        .modelContainer(for: BreadUpIngredients.self) { result in
//            if case .success(let success) = result {
//                vm.initModel(modelContext: success.mainContext)
//            }
//        }
//        WindowGroup {
//            PruebaFoundationModels(session2: LanguageModelSession())
//        }
    }
}
