//
//  StepCard.swift
//  BreadUp
//
//  Created by Yomismista on 10/06/2026.
//
import SwiftUI

struct StepCard : View {
    
    let nameStep: String
    let descriptionComplete: String
    let namespace: Namespace.ID
    
    var body : some View {
//            Image(episode.image)
//                .resizable()
//                .scaledToFill()//crece hasta llegar al primero de los límites
//                .frame(width: isiPad ? 350 : 250,
//                       height: isiPad ? 200 : 150)
//                .matchedTransitionSource(id: "cover\(episode.id)", in: namespace)
//                .clipShape(RoundedRectangle(cornerRadius: 10))//recortar de lo que salga de la entrada
//                #if os(iOS) || os(visionOS)
//                .shadow(color: .primary.opacity(0.4), radius: 5, x: 0, y: 5)//sombra SOLO para ios y vision, NO para ipad
//                #endif
//                .overlay(alignment: .bottom) {
//                    
//                    VStack(alignment: .leading) {
//                        Text(episode.name)
//                            .font(.bbBody)
//                            .matchedTransitionSource(id: "title\(episode.id)", in: namespace)
//                        Text(episode.episodeInfo)
//                            .font(.bbSubheadline)
//                            .matchedTransitionSource(id: "info\(episode.id)", in: namespace)
//                    }
//                    .multilineTextAlignment(.leading)
//                    .padding(10)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background {//Es el cartel de THE DECEPTION VERIFICATION
//                        SemiRoundedRectangle(radius: 10)
//                            .fill(Color.black.opacity(0.2))//mas contraste 0.2
//                    }
//                    .foregroundStyle(.white)
//                    
//                }
//                #if os(iOS)//padding para iOS
//                .padding(.bottom)
//                #endif   Image(episode.image)
//                .resizable()
//                .scaledToFill()//crece hasta llegar al primero de los límites
//                .frame(width: isiPad ? 350 : 250,
//                       height: isiPad ? 200 : 150)
//                .matchedTransitionSource(id: "cover\(episode.id)", in: namespace)
//                .clipShape(RoundedRectangle(cornerRadius: 10))//recortar de lo que salga de la entrada
//                #if os(iOS) || os(visionOS)
//                .shadow(color: .primary.opacity(0.4), radius: 5, x: 0, y: 5)//sombra SOLO para ios y vision, NO para ipad
//                #endif
//                .overlay(alignment: .bottom) {
//                    
//                    VStack(alignment: .leading) {
//                        Text(episode.name)
//                            .font(.bbBody)
//                            .matchedTransitionSource(id: "title\(episode.id)", in: namespace)
//                        Text(episode.episodeInfo)
//                            .font(.bbSubheadline)
//                            .matchedTransitionSource(id: "info\(episode.id)", in: namespace)
//                    }
//                    .multilineTextAlignment(.leading)
//                    .padding(10)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background {//Es el cartel de THE DECEPTION VERIFICATION
//                        SemiRoundedRectangle(radius: 10)
//                            .fill(Color.black.opacity(0.2))//mas contraste 0.2
//                    }
//                    .foregroundStyle(.white)
//                    
//                }
//                #if os(iOS)//padding para iOS
//                .padding(.bottom)
//                #endif
    }
}

//#Preview {
//    @Previewable @Namespace var namespace
//    EpisodeCard(episode: .test, namespace: namespace)
//}
