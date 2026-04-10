//
//  PruebaFoundationModelsView.swift
//  BreadUp
//
//  Created by Yomismista on 9/4/26.
//

import SwiftUI
import FoundationModels

@available(*, deprecated, renamed: "RecipeDetailview")
struct PruebaFoundationModels: View {
    
    // nos indiciará si está disponible o no
    private let model = SystemLanguageModel.default
    
    let session2: LanguageModelSession
    
    @State private var vm = BreadCalculatorVM()
    
    @State
    private var onePan: Pan.PartiallyGenerated?
    
    var body: some View {
        VStack(spacing: 20) {
            
            switch model.availability {
            case .available:
                Text("Model is available").foregroundStyle(.green)
            case .unavailable(let reason):
                Text("Model is unavailable").foregroundStyle(Color.red)
                //Text("Reason: \(reason)")// warning appendInterpolation()
            }
            
            Button("Probar FoundationModels") {
                
                Task {
                    do {
//                        try await vm.obtenerRespuestaLLM()
                        vm.calculateRecipe()
                        let prompt = "Genera una receta de pan en tan solo 5 líneas con estas cantidades en los ingredientes"
                        
                        let stream = session2.streamResponse(to: prompt, generating: Pan.self)
                        
                        for try await partial in stream {
                            // self.onePan = partial
                        }

////                        print(response.content)
////                        print(response.rawContent)
                          vm.calculateRecipe()
                    } catch {
                        print("Error: \(error.localizedDescription)")
                    }
                    
                }
            }
            ScrollView {
                if let messageMD = try? AttributedString(markdown: vm.recipe, options: options) {
                    Text(messageMD)
                        .padding()
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationTitle("Receta")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
    //      .inlineOnlyPreservingWhitespace

}

#Preview {
    PruebaFoundationModels(session2: LanguageModelSession())
}
