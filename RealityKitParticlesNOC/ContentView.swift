//
//  ContentView.swift
//  RealityKitParticlesNOC
//
//  Created by Sebastian Buys on 11/1/23.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    @StateObject var viewModel = ViewModel()
    var body: some View {
        ZStack {
            ARViewContainer(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            HUDView(viewModel: viewModel)
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    var viewModel: ViewModel
    
    func makeUIView(context: Context) -> ARView {
        return CustomARView(frame: .zero, viewModel: viewModel)
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#Preview {
    ContentView()
}
