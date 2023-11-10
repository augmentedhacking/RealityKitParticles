//
//  ViewModel.swift
//  RealityKitParticlesNOC
//
//  Created by Sebastian Buys on 11/1/23.
//

import Foundation
import Combine

class ViewModel: ObservableObject {
    @Published var usePhysics: Bool = false
    
    enum UISignal {
        case reset
    }
    
    let uiSignal = PassthroughSubject<UISignal, Never>()
}
