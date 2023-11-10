//
//  ParticleEntity.swift
//  RealityKitParticlesNOC
//
//  Created by Sebastian Buys on 11/1/23.
//

import Foundation
import RealityKit
import UIKit

/**
 ParticleEntity based on "Nature of Code" - Chapter 4
 https://natureofcode.com/book/chapter-4-particle-systems/
 */
class ParticleEntity: Entity, HasModel {
    let lifespan: Float
    private (set) var velocity: SIMD3<Float>
    private (set) var acceleration: SIMD3<Float>
    private (set) var age: Float = 0
    
    // Computed property
    // Particle is dead if age has reached lifespan
    var isDead: Bool {
        return age >= lifespan
    }
    
    init(radius: Float,
         lifespan: Float,
         initialVelocity: SIMD3<Float> = [0, 0, 0],
         acceleration: SIMD3<Float>) {
        self.lifespan = lifespan
        self.velocity = initialVelocity
        self.acceleration = acceleration
        
        super.init()
       
        let mesh = MeshResource.generateSphere(radius: radius)
        let material = SimpleMaterial(color: .red,
                                      roughness: 0.5,
                                      isMetallic: false)
        model = ModelComponent(mesh: mesh, materials: [material])
    }
    
    func update() {
        age = age + 1
        
        updateTransform()
        updateMaterial()
    }
    
    private func updateTransform() {
        // Increase velocity by acceleration
        velocity = velocity + acceleration
        
        // Translate
        transform.translation += velocity
        
        // Scale based on particle age
        let scale = age / lifespan
        transform.scale = [scale, scale, scale]
    }
    
    private func updateMaterial() {
        let alpha = (lifespan - age) / lifespan
        let color = UIColor.red.withAlphaComponent(CGFloat(alpha))
        model?.materials = [SimpleMaterial(color: color, roughness: 0.5, isMetallic: false)]
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
