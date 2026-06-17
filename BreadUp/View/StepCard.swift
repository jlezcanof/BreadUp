//
//  StepCard.swift
//  BreadUp
//
//  Created by Yomismista on 10/06/2026.
//
import SwiftUI

/// Tarjeta de un paso de la receta de pan.
///
/// Diseño tipo "ficha": badge con el número del paso, etiqueta editorial,
/// título y descripción, sobre un fondo tintado con esquinas continuas,
/// borde degradado y sombra a juego. El color rota según el número de paso
/// para que el listado resulte colorido sin perder coherencia.
struct StepCard: View {

    let number: Int
    let titulo: String
    let descripcion: String

    private var theme: (top: Color, bottom: Color) {
        Self.palette[(max(number, 1) - 1) % Self.palette.count]
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            badge
            VStack(alignment: .leading, spacing: 6) {
                Text("Paso \(number)")
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .tracking(1.2)
                    .foregroundStyle(theme.bottom)
                Text(titulo)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(descripcion)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(cardBackground)
    }

    // MARK: - Subvistas

    private var badge: some View {
        Text("\(number)")
            .font(.title2.weight(.heavy))
            .foregroundStyle(.white)
            .frame(width: 46, height: 46)
            .background {
                Circle().fill(gradient)
            }
            .overlay {
                Circle().strokeBorder(.white.opacity(0.35), lineWidth: 1)
            }
            .shadow(color: theme.bottom.opacity(0.5), radius: 5, x: 0, y: 3)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(.background)
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(theme.top.opacity(0.10))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [theme.top.opacity(0.55), theme.bottom.opacity(0.25)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: theme.bottom.opacity(0.18), radius: 12, x: 0, y: 6)
    }

    private var gradient: LinearGradient {
        LinearGradient(
            colors: [theme.top, theme.bottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Paleta cálida tipo panadería/horno

    private static let palette: [(top: Color, bottom: Color)] = [
        (Color(red: 0.99, green: 0.66, blue: 0.24), Color(red: 0.95, green: 0.40, blue: 0.15)), // ámbar → naranja tostado
        (Color(red: 0.96, green: 0.49, blue: 0.46), Color(red: 0.83, green: 0.25, blue: 0.36)), // coral → rojo corteza
        (Color(red: 0.92, green: 0.72, blue: 0.34), Color(red: 0.76, green: 0.50, blue: 0.18)), // dorado → bronce
        (Color(red: 0.56, green: 0.75, blue: 0.52), Color(red: 0.28, green: 0.56, blue: 0.36)), // verde masa madre
        (Color(red: 0.64, green: 0.57, blue: 0.88), Color(red: 0.42, green: 0.35, blue: 0.76)), // lavanda especiada
        (Color(red: 0.42, green: 0.70, blue: 0.84), Color(red: 0.20, green: 0.50, blue: 0.72)), // azul cerámica
    ]
}

#Preview("Tarjetas de pasos") {
    ScrollView {
        VStack(spacing: 16) {
            StepCard(number: 1,
                     titulo: RecipeStep.firstStep.titulo,
                     descripcion: RecipeStep.firstStep.descripcion)
            StepCard(number: 2,
                     titulo: RecipeStep.secondStep.titulo,
                     descripcion: RecipeStep.secondStep.descripcion)
            StepCard(number: 3,
                     titulo: RecipeStep.threeStep.titulo,
                     descripcion: RecipeStep.threeStep.descripcion)
            StepCard(number: 4,
                     titulo: RecipeStep.fourStep.titulo,
                     descripcion: RecipeStep.fourStep.descripcion)
            StepCard(number: 5,
                     titulo: RecipeStep.fiveStep.titulo,
                     descripcion: RecipeStep.fiveStep.descripcion)
            StepCard(number: 6,
                     titulo: RecipeStep.sixStep.titulo,
                     descripcion: RecipeStep.sixStep.descripcion)
        }
        .padding()
    }
}
