//
//  StepView.swift
//  BreadUp
//
//  Created by Yomismista on 16/4/26.
//

import SwiftUI

struct StepView: View {
    
    let step: StepRecipe
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(step.nameStep)
                .font(.headline)
            Text(step.descriptionStep)
                .font(.body)
        }
    }
}

#Preview {
    StepView(step: .example)
}
