//
//  PruebaFoundationModelsView.swift
//  BreadUp
//
//  Created by Yomismista on 9/4/26.
//

import SwiftUI
import FoundationModels

struct PruebaFoundationModels: View {
    @State private var resultado = "Pulsa para probar"

    var body: some View {
        VStack(spacing: 20) {
            Button("Probar FoundationModels") {
                Task {
                    do {
                        let session = LanguageModelSession()
                        let response = try await session.respond(
                            to: "Cuál es la mejor manera de hacer una receta de pan"
                        )
                        resultado = "\(response.rawContent)".replacingOccurrences(of: "\\n", with: "\n")
//                        print(response.content)
//                        print(response.rawContent)
                    } catch {
                        resultado = "Error: \(error.localizedDescription)"
                    }
                }
            }
            ScrollView {
                if let messageMD = try? AttributedString(markdown: resultado, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
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
    
    private static let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)

}

#Preview {
    PruebaFoundationModels()
}
