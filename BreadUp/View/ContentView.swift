//
//  ContentView.swift
//  BreadUp
//
//  Created by Jose Manuel Lezcano on 25/3/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
            NavigationStack {
                RecipeListView()
            }
        }
}

#Preview {
    ContentView()
}
