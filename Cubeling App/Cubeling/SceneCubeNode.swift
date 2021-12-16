//
//  SceneCubeNode.swift
//  Cubeling
//
//  Created by Heiko Etzold on 02.10.15.
//  MIT License
//


import UIKit
import SceneKit

class SceneCubeNode: SCNNode {

    var x : Int!
    var y : Int!
    var z : Int!

    let knobWidth = CGFloat(0.3)
    let knobHeight = CGFloat(0.1)
    let knobResolution = 50
    let chamferRadius = CGFloat(0.02)

   
    override init(){
        super.init()
        
        let touchableCube = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0)
        self.geometry = touchableCube
        let front = SCNMaterial()
        front.diffuse.contents = UIColor.clear
        let right = SCNMaterial()
        right.diffuse.contents = UIColor.clear
        let back = SCNMaterial()
        back.diffuse.contents = UIColor.clear
        let left = SCNMaterial()
        left.diffuse.contents = UIColor.clear
        let top = SCNMaterial()
        top.diffuse.contents = UIColor.clear
        let bottom = SCNMaterial()
        bottom.diffuse.contents = UIColor.clear

        touchableCube.materials = [front,right,back,left,top,bottom]
        
        if(lightMode == 0){
            
            switch typeOfCubes {
            
            //stackable cubes
            case 1:
                let cubeNode = SCNNode()
                
                let frontFaceNode = cubeFaceWithHole
                cubeNode.addChildNode(frontFaceNode)
                
                let leftFaceNode = cubeFaceWithHole
                leftFaceNode.eulerAngles.y = -Float.pi/2
                leftFaceNode.position=SCNVector3(-0.5,0,-0.5)
                cubeNode.addChildNode(leftFaceNode)
                
                let bottomFaceNode = cubeFaceWithHole
                bottomFaceNode.eulerAngles.x=Float.pi/2
                bottomFaceNode.position=SCNVector3(0,-0.5,-0.5)
                cubeNode.addChildNode(bottomFaceNode)
                
                let topFaceNode = cubeFaceWithKnob()
                topFaceNode.eulerAngles.x = -Float.pi/2
                topFaceNode.position=SCNVector3(0,0.5,-0.5)
                cubeNode.addChildNode(topFaceNode)
                
                let backFaceNode = cubeFaceWithKnob()
                backFaceNode.eulerAngles.x=Float.pi
                backFaceNode.position=SCNVector3(0, 0, -1)
                cubeNode.addChildNode(backFaceNode)
                
                let rightFaceNode = cubeFaceWithKnob()
                rightFaceNode.eulerAngles.y = -Float.pi/2
                rightFaceNode.eulerAngles.z = -Float.pi
                rightFaceNode.position=SCNVector3(0.5,0,-0.5)
                cubeNode.addChildNode(rightFaceNode)
                
                cubeNode.position=SCNVector3(0,0,0.5)
                cubeNode.categoryBitMask = HitTestType.notDetectable.rawValue
                cubeNode.name = "stackableCube"
                self.addChildNode(cubeNode)
                
            //magic cube
            case 2:
                let cube = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.02)
                let cubeNode = SCNNode(geometry: cube)
                cubeNode.name = "magicCube"
                cubeNode.categoryBitMask = HitTestType.notDetectable.rawValue
                self.addChildNode(cubeNode)
                
            //wooden cube
            default:
                let cube = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.02)
                let cubeNode = SCNNode(geometry: cube)
                cubeNode.name = "woodenCube"
                cubeNode.categoryBitMask = HitTestType.notDetectable.rawValue
                self.addChildNode(cubeNode)
            }
        }
        else{
            let cube = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0)
            let cubeNode = SCNNode(geometry: cube)
            cubeNode.categoryBitMask = HitTestType.notDetectable.rawValue
            
            if(lightMode == 1){
                switch typeOfCubes {
                    //stackable cubes
                case 1:
                    cubeNode.name = "nightStackableCube"
                    //magic cube
                case 2:
                    cubeNode.name = "nightMagicCube"
                    //wooden cube
                default:
                    cubeNode.name = "nightWoodenCube"
                }
            }
            else {
                cubeNode.name = "nightCube"
                
            }
            self.addChildNode(cubeNode)
        }
        updateColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //plane path for stackable cube
    var planePath : UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: -0.5+chamferRadius, y: -0.5+chamferRadius))
        path.addLine(to: CGPoint(x: 0.5-chamferRadius, y: -0.5+chamferRadius))
        path.addLine(to: CGPoint(x: 0.5-chamferRadius, y: 0.5-chamferRadius))
        path.addLine(to: CGPoint(x: -0.5+chamferRadius, y: 0.5-chamferRadius))
        path.close()
        return path
    }
    
    
    //cube face with hole for stackable cube
    var cubeFaceWithHole : SCNNode {
        
        let circlePath = UIBezierPath()
        circlePath.move(to: CGPoint(x: knobWidth/2, y: 0))
        for i in 1...knobResolution{
            circlePath.addLine(to: CGPoint(x: knobWidth/2*cos(CGFloat(i)*2*(.pi)/CGFloat(knobResolution)), y: knobWidth/2*sin(CGFloat(i)*2*(.pi)/CGFloat(knobResolution))))
        }
        circlePath.close()

        let path = planePath
        path.append(circlePath)
        path.usesEvenOddFillRule = true

        let shape = SCNShape(path: path, extrusionDepth: knobHeight)
        let shapeNode = SCNNode(geometry: shape)
        shapeNode.name = "stackableCubeFace"
        shapeNode.position=SCNVector3(0, 0, -knobHeight/2)
        shapeNode.categoryBitMask = HitTestType.notDetectable.rawValue
        
        let backgroundShape = SCNShape(path: planePath, extrusionDepth: knobHeight)
        let backgroundShapeNode = SCNNode(geometry: backgroundShape)
        backgroundShapeNode.name = "stackableCubeFace"
        backgroundShapeNode.position=SCNVector3(0, 0, -knobHeight/2)
        backgroundShapeNode.categoryBitMask = HitTestType.notDetectable.rawValue
        shapeNode.addChildNode(backgroundShapeNode)
        
        let edge = SCNCapsule(capRadius: chamferRadius, height: 1)
        let leftEdgeNode = SCNNode(geometry: edge)
        leftEdgeNode.position = SCNVector3(-0.5+chamferRadius, 0, -chamferRadius)
        leftEdgeNode.name = "stackableCubeFace"
        let topEdgeNode = SCNNode(geometry: edge)
        topEdgeNode.eulerAngles.z = (.pi)/2
        topEdgeNode.position = SCNVector3(0, 0.5-chamferRadius, -chamferRadius)
        topEdgeNode.name = "stackableCubeFace"

        let cubeFace = SCNNode()
        cubeFace.name = "stackableCubeFace"
        cubeFace.addChildNode(shapeNode)
        cubeFace.addChildNode(leftEdgeNode)
        cubeFace.addChildNode(topEdgeNode)
        cubeFace.categoryBitMask = HitTestType.notDetectable.rawValue

        return cubeFace
    }
    
    //cube face with knob for stackable cube
    func cubeFaceWithKnob() -> SCNNode {
            
        let circlePath = UIBezierPath()
        circlePath.move(to: CGPoint(x: knobWidth/2, y: 0))
        for i in 1...knobResolution{
            circlePath.addLine(to: CGPoint(x: knobWidth/2*cos(CGFloat(i)*2*(.pi)/CGFloat(knobResolution)), y: knobWidth/2*sin(CGFloat(i)*2*(.pi)/CGFloat(knobResolution))))
        }
        circlePath.close()

        let shape = SCNShape(path: planePath, extrusionDepth: knobHeight)
        let shapeNode = SCNNode(geometry: shape)
        shapeNode.name = "stackableCubeFace"
        shapeNode.position=SCNVector3(0, 0, -knobHeight/2)

        let knob = SCNShape(path: circlePath, extrusionDepth: knobHeight)
        let knobNode = SCNNode(geometry: knob)
        knobNode.name = "stackableCubeFace"
        knobNode.position=SCNVector3(0, 0, knobHeight/2)
        knobNode.categoryBitMask = HitTestType.notDetectable.rawValue

        shapeNode.addChildNode(knobNode)
        shapeNode.categoryBitMask = HitTestType.notDetectable.rawValue
        
        let edge = SCNCapsule(capRadius: chamferRadius, height: 1)
        let rightEdgeNode = SCNNode(geometry: edge)
        rightEdgeNode.name = "stackableCubeFace"
        rightEdgeNode.position = SCNVector3(0.5-chamferRadius, 0, -chamferRadius)
        let topEdgeNode = SCNNode(geometry: edge)
        topEdgeNode.name = "stackableCubeFace"
        topEdgeNode.eulerAngles.z = (.pi)/2
        topEdgeNode.position = SCNVector3(0, 0.5-chamferRadius, -chamferRadius)
        
        let cubeFace = SCNNode()
        cubeFace.addChildNode(shapeNode)
        cubeFace.addChildNode(rightEdgeNode)
        cubeFace.addChildNode(topEdgeNode)
        cubeFace.categoryBitMask = HitTestType.notDetectable.rawValue
        cubeFace.name = "stackableCubeFace"
        
        return cubeFace
    }
    
    
    //update color/texture of cube
    func updateColor(){
        //wooden cube
        let woodenTexture = SCNMaterial()
        woodenTexture.lightingModel = .physicallyBased
        woodenTexture.diffuse.contents = UIColor.systemOrange
        woodenTexture.multiply.contents = UIImage(named: "woodenTexture")
        woodenTexture.roughness.contents = UIImage(named: "woodenRoughTexture")

        let cuttenWoodenTexture = SCNMaterial()
        cuttenWoodenTexture.lightingModel = .physicallyBased
        cuttenWoodenTexture.diffuse.contents = UIColor.systemOrange
        cuttenWoodenTexture.multiply.contents = UIImage(named: "woodenCuttedTexture")
        cuttenWoodenTexture.roughness.contents = UIImage(named: "woodenCuttedRoughTexture")

        for node in self.childNodes.filter({$0.name == "woodenCube"}){
            node.geometry!.materials = [woodenTexture,cuttenWoodenTexture,woodenTexture,cuttenWoodenTexture,woodenTexture,woodenTexture]
        }


        //magic cube
        let magicTexture = SCNMaterial()
        magicTexture.lightingModel = .physicallyBased
        magicTexture.diffuse.contents = UIColor.systemPink
        magicTexture.metalness.contents = UIImage(named: "magicTexture")
        for node in self.childNodes.filter({$0.name == "magicCube"}){
            node.geometry!.materials = [magicTexture]
        }
        
        
        //stackable cube
        let stackedTexture = SCNMaterial()
        stackedTexture.lightingModel = .physicallyBased
        stackedTexture.multiply.contents = UIImage(named: "stackableRoughTexture")
        stackedTexture.roughness.contents = UIImage(named: "stackableRoughTexture")
        stackedTexture.diffuse.contents = UIColor.systemYellow
        for node in self.childNodes.filter({$0.name == "stackableCube"}){
            for childNode in node.childNodes.filter({$0.name == "stackableCubeFace"}){
                for subChildNode in childNode.childNodes.filter({$0.name == "stackableCubeFace"}){
                    subChildNode.geometry!.materials = [stackedTexture]
                    for subSubChildNode in subChildNode.childNodes.filter({$0.name == "stackableCubeFace"}){
                        subSubChildNode.geometry!.materials = [stackedTexture]
                    }
                }
            }
        }
        
        //night cube
        let nightWoodenTexture = SCNMaterial()
        nightWoodenTexture.diffuse.contents = UIColor.systemOrange
        for node in self.childNodes.filter({$0.name == "nightWoodenCube"}){
            node.geometry!.materials = [nightWoodenTexture]
        }
        
        let nightStackableTexture = SCNMaterial()
        nightStackableTexture.diffuse.contents = UIColor.systemYellow
        for node in self.childNodes.filter({$0.name == "nightStackableCube"}){
            node.geometry!.materials = [nightStackableTexture]
        }
        
        let nightMagicTexture = SCNMaterial()
        nightMagicTexture.diffuse.contents = UIColor.systemPink
        for node in self.childNodes.filter({$0.name == "nightMagicCube"}){
            node.geometry!.materials = [nightMagicTexture]
        }
        
        let nightTexture = SCNMaterial()
        nightTexture.diffuse.contents = UIColor.black
        for node in self.childNodes.filter({$0.name == "nightCube"}){
            node.geometry!.materials = [nightTexture]
        }
    }
}
