//
//  CustomARView.swift
//  RealityKitParticlesNOC
//
//  Created by Sebastian Buys on 11/1/23.
//

import Foundation
import ARKit
import Combine
import RealityKit

class CustomARView: ARView {
    var subscriptions = Set<AnyCancellable>()
    
    var viewModel: ViewModel
    
    // Particle emitter "nature of code" style
    var particleEmitterEntity: ParticleEmitterEntity?
    
    // Particle emitter using physics
    var physicsParticleEmitterEntity: PhysicsParticleEmitterEntity?
    
    // World origin anchor
    var worldOriginAnchor: AnchorEntity?
    
    // Camera anchor
    var povAnchor: AnchorEntity?
    
    // Custom initializer
    init(frame: CGRect, viewModel: ViewModel) {
        self.viewModel = viewModel
        
        // Call superclass initializer
        super.init(frame: frame)
    }
    
    // Required initializer when subclassing ARView. Since we want to use our custom initializer, we throw a fatalError to stop execution of our app.
    required init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    // Required initializer when subclassing ARView. Since we want to use our custom initializer, we throw a fatalError to stop execution of our app.
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // The default implementation of this method does nothing. Subclasses can override it to perform additional actions whenever the superview changes.
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        self.setupARSession()
        self.setupScene()
    }
    
    // MARK: - AR methods
    
    // Setup ARSession configuration
    private func setupARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .meshWithClassification

        environment.sceneUnderstanding.options = []
        
        // Turn on occlusion from the scene reconstruction's mesh.
        environment.sceneUnderstanding.options.insert(.occlusion)
        
        // Turn on physics for the scene reconstruction's mesh.
        environment.sceneUnderstanding.options.insert(.physics)

        // Display a debug visualization of the mesh.
        debugOptions.insert(.showSceneUnderstanding)
        
        // For performance, disable render options that are not required for this app.
        renderOptions = [.disablePersonOcclusion, .disableDepthOfField, .disableMotionBlur]
        
        // Run session with configuration
        self.session.run(configuration)
        
        // Process UI signals.
        viewModel.uiSignal.sink { [weak self] in
            self?.processUISignal($0)
        }.store(in: &subscriptions)
        
        // Listen for changes to viewModel.usePhysics
        // Switch between particle emitters
        viewModel.$usePhysics.dropFirst().sink { usePhysics in
            self.particleEmitterEntity?.stop()
            self.physicsParticleEmitterEntity?.stop()
            self.setupARSession()
            self.setupScene()
        }.store(in: &subscriptions)
        
        // Setup update loop
        self.scene.publisher(for: SceneEvents.Update.self).sink { [weak self] update in
            guard let self = self else { return }
            self.update()
           
        }.store(in: &subscriptions)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            if (self.viewModel.usePhysics) {
                self.runWithPhysics()
            } else {
                self.runWithoutPhysics()
            }
        }
    }
    
    private func setupScene() {
        // Remove any potential anchors from previous session
        self.scene.anchors.removeAll()
        
        let worldOriginAnchor = AnchorEntity(world: .zero)
        self.scene.addAnchor(worldOriginAnchor)
        self.worldOriginAnchor = worldOriginAnchor
        
        let povAnchor = AnchorEntity(.camera)
        self.povAnchor = povAnchor
        self.scene.addAnchor(povAnchor)
        
    }
    
    private func runWithoutPhysics() {
        let particleEmitter = ParticleEmitterEntity(count: 100, radius: 0.05, maxAcceleration: 0.0002, maxLifespan: 100.0, world: worldOriginAnchor)
        
        // Add particle emitter to pov anchor (camera)
        self.povAnchor?.addChild(particleEmitter)
        
        // Position particle system 0.5 meters in front of camera
        particleEmitter.transform.matrix = float4x4(translation: [0.0, 0.0, -0.5])
        
        // Start emitting
        particleEmitter.start()
        
        self.particleEmitterEntity = particleEmitter
    }
    
    private func runWithPhysics() {
        let physicsParticleEmitter = PhysicsParticleEmitterEntity(count: 200, radius: 0.1, maxImpulseMagnitude: 10, maxLifespan: 3, world: worldOriginAnchor)
        
        // Add particle emitter to pov anchor (camera)
        self.povAnchor?.addChild(physicsParticleEmitter)
        
        // Position particle system 0.5 meters in front of camera
        physicsParticleEmitter.transform.matrix = float4x4(translation: [0.0, 0.0, -0.5])
        self.physicsParticleEmitterEntity = physicsParticleEmitter
        
        physicsParticleEmitter.start()
    }
    
    // Helper function for our update logic
    private func update() {
        if (viewModel.usePhysics) {
            physicsParticleEmitterEntity?.update()
        } else {
            particleEmitterEntity?.update()
        }
    }
    
    // Handle UI signals
    private func processUISignal(_ signal: ViewModel.UISignal) {
        switch signal {
        case .reset:
            break
        }
    }
}
