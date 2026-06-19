//
//  LoadingOverlay.swift
//  BreadUp
//

import SwiftUI

/// Velo de carga reutilizable: atenúa el contenido subyacente, bloquea la
/// interacción y muestra un indicador con un mensaje sobre material del sistema.
///
/// Usa colores semánticos (`.primary`, tint del sistema) en lugar de blanco
/// fijo, de modo que el contenido sea legible tanto en claro como en oscuro.
struct LoadingOverlayModifier: ViewModifier {

    let isLoading: Bool
    let message: String

    func body(content: Content) -> some View {
        content
            .overlay {
                if isLoading {
                    ZStack {
                        // Velo que atenúa el contenido de fondo.
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()

                        VStack(spacing: 16) {
                            ProgressView()
                                .controlSize(.large)
                            Text(message)
                                .font(.headline)
                        }
                        .padding(32)
                        .background(
                            .ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: isLoading)
            .allowsHitTesting(!isLoading)
    }
}

extension View {
    /// Superpone un velo de carga mientras `isLoading` sea `true` y bloquea la
    /// interacción con el contenido subyacente.
    func loadingOverlay(_ isLoading: Bool, message: String = "Cargando…") -> some View {
        modifier(LoadingOverlayModifier(isLoading: isLoading, message: message))
    }
}
