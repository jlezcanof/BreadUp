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

    @ScaledMetric(relativeTo: .title2) private var badgeSize: CGFloat = 46

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
        .accessibilityElement(children: .combine)
    }

    // MARK: - Subvistas

    private var badge: some View {
        Text("\(number)")
            .font(.title2.weight(.heavy))
            .foregroundStyle(.white)
            .frame(width: badgeSize, height: badgeSize)
            .background {
                Circle().fill(gradient)
            }
            .overlay {
                Circle().strokeBorder(.white.opacity(0.35), lineWidth: 1)
            }
            .shadow(color: theme.bottom.opacity(0.5), radius: 5, x: 0, y: 3)
            .accessibilityHidden(true)
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
        (Color("Step1Top"), Color("Step1Bottom")), // ámbar → naranja tostado
        (Color("Step2Top"), Color("Step2Bottom")), // coral → rojo corteza
        (Color("Step3Top"), Color("Step3Bottom")), // dorado → bronce
        (Color("Step4Top"), Color("Step4Bottom")), // verde masa madre
        (Color("Step5Top"), Color("Step5Bottom")), // lavanda especiada
        (Color("Step6Top"), Color("Step6Bottom")), // azul cerámica
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
