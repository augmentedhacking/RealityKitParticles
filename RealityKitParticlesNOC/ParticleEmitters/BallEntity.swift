//
//  BallEntity.swift
//  RealityKitParticlesNOC
//
//  Created by Sebastian Buys on 11/2/23.
//

import Foundation
import RealityKit

class Ball: Entity, HasModel, HasCollision, HasPhysics {
    required init() {
        super.init()
        
        let mesh = MeshResource.generateSphere(radius: 1.0)
        let material = SimpleMaterial()
        let model = ModelComponent(mesh: mesh, materials: [material])
        self.model = model
        
        let shape = ShapeResource.generateSphere(radius: 1.0)
        self.collision = CollisionComponent(shapes: [shape])
        self.physicsBody = PhysicsBodyComponent(shapes: [shape], mass: 1.0)
    }
    
}
