//
//  HUDView.swift
//  RealityKitParticlesNOC
//
//  Created by Sebastian Buys on 11/1/23.
//

import Foundation
import SwiftUI

struct HUDView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack(alignment: .trailing) {
            Button {
                viewModel.usePhysics.toggle()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .padding()
            }
            .controlSize(.large)
            .background(.ultraThinMaterial, in: .circle)
            .foregroundColor(.white)
            HStack {
                Spacer()
            }
            Spacer()
        }.padding()
    }
}
