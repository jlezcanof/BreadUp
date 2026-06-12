//
//  StepView.swift
//  BreadUp
//
//  Created by Yomismista on 16/4/26.
//

import SwiftUI

struct StepView: View {
    
    let step: RecipeStep
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(step.titulo)
                .font(.headline)
            Text(step.descripcion)
                .font(.body)
        }
    }
}

#Preview {
    StepView(step: .example)
}
