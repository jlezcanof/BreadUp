//
//  StepsBreadView.swift
//  BreadUp
//
//  Created by Yomismista on 10/06/2026.
//

import SwiftUI

struct StepsBreadView: View {
//    @Environment(BigBangVM.self) private var vm// de esta manera puedo tener el state del view-model
//    
//    // En caso de que hiciéramos una modificación en cualquiera de los valores del state, se pasaría como Bindable
//    
//    let season: Int
//    let namespace: Namespace.ID
//    
//    var body: some View {
//        Section {
//            ScrollView(.horizontal, showsIndicators: false) {
//                LazyHStack(spacing: 20) {
//                    ForEach(vm.getEpisodesAtSeason(season)) { episode in
////                        NavigationLink(value: episode) {
////                            EpisodeCard(episode: episode, namespace: namespace)
////                        }
//                        #if os(iOS)
//                        Button {
//                            vm.selectedEpisode = episode
//                        } label: {
//                            EpisodeCard(episode: episode, namespace: namespace)
//                            #if os(iOS) || os(visionOS)
//                            .hoverEffect(.highlight)
//                            #endif
//                             // Cuando yo puedo decirle al sistema cuando estoy con el ratón del ipad como quiero que reacccione la interfaz cuando pase el raton por encima (un brillo ó se levante), es la forma correcta de moverse
//                        }
//                        .buttonBorderShape(.roundedRectangle(radius: 10))
//                        .buttonStyle(.plain)
//                        #elseif os(macOS) || os(visionOS)
//                        NavigationLink(value: episode) {
//                            EpisodeCard(episode: episode, namespace: namespace)
//                        }
//                        .buttonStyle(.plain)
//                        .buttonBorderShape(.roundedRectangle(radius: 10))
//                        #elseif os(tvOS)
//                        NavigationLink(value: episode) {
//                            EpisodeCard(episode: episode, namespace: namespace)
//                        }
//                        .buttonStyle(.card)
//                        #endif
//                    }
//                }
//                #if os(tvOS)
//                .frame(height: 250)
//                #endif
//            }
//        } header: {
//            HStack {
//                Text("Season [\(season)]")
//                    .font(.bbTitle)
//                Spacer()
//                Image("season\(season)")
//                    .resizable()
//                    .scaledToFit()
//                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                    .frame(height: isiPad ? 100 : 50)
//            }
//            .padding(.top)
//        }
//    }
    
    var body : some View {
        ContentUnavailableView("Nada de nada", image: "cookfill.tip")
    }
}


//al marcar el modo selectable, tendría un layout/tamaño más pequeño para tener una preview de una manera más controlada
//#Preview(traits: .fixedLayout(width: 390, height: 200)) {
//    @Previewable @Namespace var namespace
//    SeasonsView(season: 1, namespace: namespace)
//        .environment(BigBangVM(repository: RepositoryTest()))
//}
