//
//  ParticleEmitterEntity.swift
//  RealityKitParticlesNOC
//
//  Created by Sebastian Buys on 11/1/23.
//

import Foundation
import RealityKit

/**
 ParticleEmitterEntity based on "Nature of Code" - Chapter 4
 https://natureofcode.com/book/chapter-4-particle-systems/
 */
class ParticleEmitterEntity: Entity {
    private (set) weak var world: Entity?
    private (set) var particles: [ParticleEntity] = []
    private (set) var radius: Float
    private (set) var maxAcceleration: Float
    private (set) var maxLifespan: Float
    private (set) var count: Int
    
    init(count: Int,
         radius: Float,
         maxAcceleration: Float,
         maxLifespan: Float,
         world: Entity? = nil) {
        self.count = count
        self.radius = radius
        self.maxAcceleration = abs(maxAcceleration)
        self.maxLifespan = maxLifespan
        self.world = world
        super.init()
    }
    
    func start() {
        for _ in 0...self.count {
            addParticle()
        }
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    func update() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Iterate in reverse order so indices remain valid while removing particles
            for (index, particle) in particles.enumerated().reversed() {
                particle.update()
                
                // If particle is dead, remove and create a new particle
                if (particle.isDead) {
                    particle.removeFromParent()
                    self.particles.remove(at: index)
                    self.addParticle()
                }
            }
        }
    }
    
    private func addParticle() {
        let acceleration: SIMD3<Float> = [
            Float.random(in: 0...0),
            Float.random(in: 0...0),
            Float.random(in: -maxAcceleration...(-maxAcceleration / 2.0)) // always away
        ]
        
        let lifespan = Float.random(in: maxLifespan / 2...maxLifespan)
        
        let particleEntity = ParticleEntity(radius: radius,
                                            lifespan: lifespan,
                                            acceleration: acceleration)
        
        particles.append(particleEntity)
        

        // If system was constructed with world entity, add particle to world hierarchy instead of the system
        if let world = self.world {
            let transformMatrix = self.transformMatrix(relativeTo: world)
            
            particleEntity.transform.matrix = transformMatrix
            
            // Start small
            particleEntity.scale = [0, 0, 0]
            
            world.addChild(particleEntity)
        } else {
            self.addChild(particleEntity)
        }
    }
    
    func stop() {
        self.particles.forEach { particle in
            particle.removeFromParent()
        }
        self.particles = []
    }
}
