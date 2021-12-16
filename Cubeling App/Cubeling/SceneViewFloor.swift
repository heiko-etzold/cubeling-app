//
//  SceneViewFloor.swift
//  Cubeling
//
//  Created by Heiko Etzold on 02.06.16.
//  MIT License
//


import UIKit
import SceneKit

class SceneViewFloor: SCNNode {
    
    var x : Int!
    var y : Int!
    let planeGeometry = SCNPlane(width: 1.0, height: 1.0)
    let planeNode = SCNNode()
    
    init(x: Int, y: Int){
        super.init()
        
        self.x = x
        self.y = y
        
        planeNode.geometry = planeGeometry
        updateColor()
        adjustPlaneNode()
        self.addChildNode(planeNode)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func adjustPlaneNode(){
        planeNode.position = SCNVector3(x: Float(x)-Float(numberOfFields)/2-0.5, y: -0.5, z: Float(numberOfFields)/2-Float(y)+0.5)
        planeNode.eulerAngles.x = -Float.pi/2
        planeNode.categoryBitMask  = HitTestType.detectable.rawValue
    }
    
    
    func updateColor(){
        let lightgrayMaterial = SCNMaterial()
        lightgrayMaterial.diffuse.contents = lightFloorColor
        let grayMaterial = SCNMaterial()
            grayMaterial.diffuse.contents = darkFloorColor
        
        if((x+y)%2==0){
            planeGeometry.materials = [lightgrayMaterial]
        }
        else{
            planeGeometry.materials = [grayMaterial]
        }
    }
}



class SceneViewFlippedFloor: SceneViewFloor {

    override func adjustPlaneNode(){
        planeNode.position = SCNVector3(x: Float(x)-Float(numberOfFields)/2-0.5, y: -0.51, z: Float(numberOfFields)/2-Float(y)+0.5)
        planeNode.eulerAngles.x = +Float.pi/2
        planeNode.opacity = 0.5
        planeNode.categoryBitMask  = HitTestType.notDetectable.rawValue
    }
}
