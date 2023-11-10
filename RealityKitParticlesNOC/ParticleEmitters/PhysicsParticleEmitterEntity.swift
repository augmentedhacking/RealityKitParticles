//
//  PhysicsParticleEmitterEntity.swift
//  RealityKitParticlesNOC
//
//  Created by Sebastian Buys on 11/2/23.
//

import Combine
import Foundation
import RealityKit

class PhysicsParticleEmitterEntity: Entity {
    var subscriptions = Set<AnyCancellable>()
    
    private (set) var count: Int
    private (set) var maxImpulseMagnitude: Float
    private (set) var maxLifespan: Double
    private (set) weak var world: Entity?
    
    private (set) var particles: [PhysicsParticleEntity] = []
    private (set) var radius: Float

    init(count: Int,
         radius: Float,
         maxImpulseMagnitude: Float,
         maxLifespan: Double,
         world: Entity? = nil) {
        self.radius = radius
        self.maxImpulseMagnitude = abs(maxImpulseMagnitude)
        self.maxLifespan = maxLifespan
        self.world = world
        self.count = count
        super.init()
    }
    
    func start() {
        setupCollisionsHandler()
        
        for _ in 0...self.count {
            addParticle()
        }
    }
    
    func update() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Iterate in reverse order so indices remain valid while removing particles
            for (index, particle) in particles.enumerated().reversed() {
                particle.update()
                
                // If particle is older than max lifespan, it has not yet collided with environment
                // Remove and create a new particle
                if particle.isDead {
                    particle.removeFromParent()
                    self.particles.remove(at: index)
                    self.addParticle()
                }
            }
        }
    }
    
    private func setupCollisionsHandler() {
        // Called every frame.
        self.scene?.subscribe(to: CollisionEvents.Began.self) { [weak self] event in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // Change particle color after collision
                if let particleA = event.entityA as? PhysicsParticleEntity, let _ = self.particles.firstIndex(of: particleA) {
                    particleA.model?.materials = [SimpleMaterial(color: .blue, isMetallic: false)]
                }
                
                if let particleB = event.entityB as? PhysicsParticleEntity, let _ = self.particles.firstIndex(of: particleB) {
                    particleB.model?.materials = [SimpleMaterial(color: .blue, isMetallic: false)]
                }
            }
        }.store(in: &subscriptions)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }

    private func addParticle() {
        // Apply linear impulse in up and forward direction
        let magnitude = Float.random(in: -maxImpulseMagnitude...(-maxImpulseMagnitude / 2.0)) // always away
        let impulse: SIMD3<Float> = [0, 2.5, magnitude]
        
        // Random lifespan
        let lifespan = Double.random(in: maxLifespan / 2.0...maxLifespan)
        
        let particleEntity = PhysicsParticleEntity(radius: radius,
                                                   mass: 1.0,
                                                   lifespan: lifespan )
        particles.append(particleEntity)
        
        // Add particle to world hierarchy instead of the system
        if let world = self.world {
            let transformMatrix = self.transformMatrix(relativeTo: world)
            particleEntity.transform.matrix = transformMatrix
            world.addChild(particleEntity)
        } else {
           //  self.addChild(particleEntity)
        }
        
        particleEntity.applyLinearImpulse(impulse, relativeTo: self)
        particleEntity.scale = [0, 0, 0]
    }
    
    func stop() {
        self.particles.forEach { particle in
            particle.removeFromParent()
        }
        self.particles = []
    }
}

