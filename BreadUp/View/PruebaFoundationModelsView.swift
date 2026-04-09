//
//  PruebaFoundationModelsView.swift
//  BreadUp
//
//  Created by Yomismista on 9/4/26.
//

import SwiftUI
import FoundationModels

struct PruebaFoundationModels: View {
    
    let session2: LanguageModelSession
    
    @State private var vm = BreadCalculatorVM()
    
    @State
    private var onePan: Pan.PartiallyGenerated?
    
    //@State private var resultado = "" // Pulsa para probar

    var body: some View {
        VStack(spacing: 20) {
            Button("Probar FoundationModels") {
                
                Task {
                    do {
                          try await vm.obtenerRespuestaLLM()
                                                
                        let prompt = "Genera una receta de pan en tan solo 5 líneas con estas cantidades en los ingredientes"
                        
                        let stream = session2.streamResponse(to: prompt, generating: Pan.self)
                        
                        for try await partial in stream {
                            // self.onePan = partial
                        }

////                        print(response.content)
////                        print(response.rawContent)
                    } catch {
                        print("Error: \(error.localizedDescription)")
                        // resultado = "Error: \(error.localizedDescription)"
                    }
                    
                }
            }
            ScrollView {
                if let messageMD = try? AttributedString(markdown: vm.resultado, options: options) {
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
