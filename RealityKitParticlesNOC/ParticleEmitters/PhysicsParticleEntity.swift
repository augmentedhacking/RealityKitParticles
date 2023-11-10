//
//  PhysicsParticleEntity.swift
//  RealityKitParticlesNOC
//
//  Created by Sebastian Buys on 11/2/23.
//

import Foundation
import RealityKit
import UIKit

class PhysicsParticleEntity: Entity, HasModel, HasCollision, HasPhysics {
    let birthday: Date = .now
    let lifespan: Double
    
    var age: Double {
        return abs(birthday.timeIntervalSinceNow)
    }
    
    var isDead: Bool {
        return age > lifespan
    }
    
    init(radius: Float, mass: Float, lifespan: Double) {
        self.lifespan = lifespan
        super.init()
        
        let mesh = MeshResource.generateSphere(radius: radius)
        let material = SimpleMaterial(color: .red, isMetallic: false)
        model = ModelComponent(mesh: mesh, materials: [material])
        
        let sphereShape = ShapeResource.generateSphere(radius: radius)
        
        // Add CollisionComponent and PhysicsBodyComponent
        collision = CollisionComponent(shapes: [sphereShape])
        physicsBody = PhysicsBodyComponent(shapes: [sphereShape], mass: mass)
    
        // Add collision filter so particles don't hit each other
        let collisionGroup = CollisionGroup(rawValue: 1 << 0)
        
        // Create a collision mask, subtracting this collision group from the "all" group
        // "all.subtracting" gives a filter that collides with everything except the subtracted group
        let collisionMask = CollisionGroup.all.subtracting(collisionGroup)
        let collisionFilter = CollisionFilter(group: collisionGroup, mask: collisionMask)

        // Add collision filter to the model
        self.collision?.filter = collisionFilter
    }
    
    func update() {
        updateTransform()
    }
    
    private func updateTransform() {
        // Set scale based on age / lifespan
        let lifespanPct = age / lifespan
      
        // Use easing function for smooth transition
        let scale = (easeOutSine(x: Float(lifespanPct)) + 0.1) / 1.1
        
        transform.scale = [scale, scale, scale]
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}

func easeOutSine(x: Float) -> Float {
    return sin((x * .pi) / 2);
}
