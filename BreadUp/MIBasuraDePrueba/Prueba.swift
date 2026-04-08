//
//  Prueba.swift
//  BreadUp
//
//  Created by Yomismista on 8/4/26.
//
import UIKit

// Ejemplo con patrón delegado, donde el delegate siempre vive más que el objeto
protocol AnalyticsDelegate: AnyObject {
    func didTrackEvent(_ name: String)
}

final class AnalyticsTracker {
    // El tracker no debe retener al delegate: ciclo de retención típico
    weak var delegate: AnalyticsDelegate?

    func track(_ event: String) {
        delegate?.didTrackEvent(event)
    }
}

//
//🔄 Los closures son la fuente más habitual de ciclos de retención en código real, especialmente en arquitecturas con ViewModels, Combine o async/await con continuaciones almacenadas. El patrón clásico es un objeto que retiene un closure que captura al propio objeto:

final class ImageLoader {
    var onLoad: ((UIImage?) -> Void)?

    func load(url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }
            let image = data.flatMap(UIImage.init)
            self.onLoad?(image)
        }.resume()
    }
}
