//
//  SceneView.swift
//  Cubeling
//
//  Created by Heiko Etzold on 06.08.15.
//  MIT License
//


import UIKit
import SceneKit

class SceneView: SCNView, UIPopoverPresentationControllerDelegate, UIPointerInteractionDelegate {

    var setOfCubesNodes = Set<SceneCubeNode>()
    var xCurtainIsVisible = Bool(false)
    var yCurtainIsVisible = Bool(false)
    var floorIsVisible = Bool(false)
    var cubesAreVisible = Bool(true)
    var cubeOpacity = Float(1)

    var cameraNode = SCNNode()
    var cameraOrbit = SCNNode()
    var lightOrbit = SCNNode()

    let codeTracingOverlay = UIView()
    let informationLabel = UILabel()
    
    var multiViewAxisNode = SCNNode()
    var isometricAxisNode = SCNNode()
    

    override init(frame: CGRect, options: [String : Any]?) {
        
        super.init(frame: frame, options: nil)
        
        //floor cube, necessary for deep search
        setOfCubes.insert(Cube(x: -1,y: -1,z: 0,visited: false))

        
        //scene
        let scene = SCNScene()
        self.scene = scene
        self.backgroundColor = systemBackgroundColor

        
        //camera
        let camera = SCNCamera()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        cameraOrbit.name = "fixedNode"
        cameraOrbit.eulerAngles.x = -Float.pi * 0.15
        cameraOrbit.addChildNode(cameraNode)
        scene.rootNode.addChildNode(cameraOrbit)

        
        
        //lights
        let directionalLight = SCNLight()
        directionalLight.type = SCNLight.LightType.directional
        directionalLight.intensity = 850
        let directionalLightNode = SCNNode()
        directionalLightNode.name = "fixedNode"
        directionalLightNode.light = directionalLight
        directionalLightNode.eulerAngles = SCNVector3(-0.35*Float.pi, -0.2*Float.pi, 0)
        //|x| > 0.25 ==> more from top then from side
        //|y| < 0.25 ==> more from front then from left side
        
        lightOrbit.name = "fixedNode"
        //        lightOrbit.eulerAngles.x = -Float.pi * 0.15
        //        scene.rootNode.addChildNode(directionalLightNode)
        lightOrbit.addChildNode(directionalLightNode)
        scene.rootNode.addChildNode(lightOrbit)


        
        
        let ambientLight = SCNLight()
        ambientLight.type = SCNLight.LightType.ambient
        ambientLight.intensity = 250
        let ambientLightNode = SCNNode()
        ambientLightNode.name = "fixedNode"
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)
        
        
        //reload content
        reloadContent(newNumberOfFields: numberOfFields, newTypesOfCubes: typeOfCubes)

        
        //add gestures
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture));
        if #available(iOS 13.4, *) {
            gesture.allowedScrollTypesMask = .continuous
        }
        self.addGestureRecognizer(gesture)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture));
        self.addGestureRecognizer(pinch);
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(sceneTapped));
        self.addGestureRecognizer(tap);
        
        let longtap = UILongPressGestureRecognizer(target: self, action: #selector(sceneLongTapped));
        self.addGestureRecognizer(longtap);
        
        
        //overlay, when code is tracing
        codeTracingOverlay.isUserInteractionEnabled = false
        codeTracingOverlay.backgroundColor = separatorColor.withAlphaComponent(0.2)
        codeTracingOverlay.alpha = 0
        self.addSubview(codeTracingOverlay)
        codeTracingOverlay.translatesAutoresizingMaskIntoConstraints = false
        codeTracingOverlay.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        codeTracingOverlay.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        codeTracingOverlay.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        codeTracingOverlay.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        let codeTracingOverlayLabel = UILabel()
        codeTracingOverlayLabel.text = "CodeRunningActive".localized()
        codeTracingOverlayLabel.font = UIFont.boldSystemFont(ofSize: codeTracingOverlayLabel.font.pointSize)
        codeTracingOverlayLabel.numberOfLines = -1
        codeTracingOverlayLabel.sizeToFit()
        codeTracingOverlay.addSubview(codeTracingOverlayLabel)
        codeTracingOverlayLabel.translatesAutoresizingMaskIntoConstraints = false
        codeTracingOverlayLabel.leftAnchor.constraint(equalTo: codeTracingOverlay.leftAnchor, constant: 100).isActive = true
        codeTracingOverlayLabel.rightAnchor.constraint(equalTo: codeTracingOverlay.rightAnchor, constant: -20).isActive = true
        codeTracingOverlayLabel.bottomAnchor.constraint(equalTo: codeTracingOverlay.bottomAnchor, constant: -15).isActive = true
        
        
        //information, when cube is outside the grid
        self.addSubview(informationLabel)
        informationLabel.translatesAutoresizingMaskIntoConstraints = false
        informationLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        informationLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        informationLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        informationLabel.numberOfLines = -1
        informationLabel.text = "HintShadowLabelText".localized()
        
        
        /*
        //to create app icon; set numberOfFields to 6
        camera.usesOrthographicProjection = true
        cameraOrbit.eulerAngles.x = -1.2*Float.pi/6
        cameraOrbit.eulerAngles.y = -Float.pi/4
        cameraOrbit.eulerAngles.z = 0
        */
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    
    func createContent(){
        
        //remove all nodes (except camera and light)
        for node in self.scene!.rootNode.childNodes.filter({$0.name != "fixedNode"}){
            node.removeFromParentNode()
        }
        
    
        //create multiview axis
        let axis = SCNCylinder(radius: 0.05, height: CGFloat(numberOfFields)+0.2)
        multiViewAxisNode = SCNNode(geometry: axis)
        multiViewAxisNode.eulerAngles.z=Float.pi/2
        multiViewAxisNode.position = SCNVector3(x: 0, y: -0.5, z: -Float(numberOfFields)/2-0.5)
        multiViewAxisNode.name = "axis"

        let axisCube = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
        let axisCubeNode = SCNNode(geometry: axisCube)
        axisCubeNode.position = SCNVector3(x: 0, y: Float(numberOfFields)/2+0.1, z: 0)
        multiViewAxisNode.addChildNode(axisCubeNode)
        
        let axisSphere = SCNSphere(radius: 0.1)
        let axisSphereNode = SCNNode(geometry: axisSphere)
        axisSphereNode.position = SCNVector3(x: 0, y: -Float(numberOfFields)/2-0.1, z: 0)
        multiViewAxisNode.addChildNode(axisSphereNode)
    
        self.scene?.rootNode.addChildNode(multiViewAxisNode)
        hideMultiViewAxis()
    
        
        //create isometric axis
        let isometricAxis = SCNCylinder(radius: 0.02, height: 1.0)
        isometricAxisNode = SCNNode(geometry: isometricAxis)
        isometricAxisNode.position = SCNVector3(x: 2-Float(numberOfFields)/2, y: 0, z: Float(numberOfFields)/2-2)
        isometricAxisNode.eulerAngles.y=Float(CGFloat.pi/2)
        isometricAxisNode.name = "isoaxis"
        self.scene?.rootNode.addChildNode(isometricAxisNode)
        hideIsometricAxis()
        
        
        //create floor planes
        for x in 1 ... numberOfFields{
            for y in 1 ... numberOfFields{
                let planeNode = SceneViewFloor(x: x, y: y)
                planeNode.categoryBitMask  = HitTestType.detectable.rawValue
                self.scene!.rootNode.addChildNode(planeNode)
                let flippedPlaneNode = SceneViewFlippedFloor(x: x, y: y)
                flippedPlaneNode.categoryBitMask  = HitTestType.notDetectable.rawValue
                self.scene!.rootNode.addChildNode(flippedPlaneNode)
            }
        }
        
        
        //create colored axes
        let xAxisPlane = SCNPlane(width: CGFloat(numberOfFields), height: 0.9)
        let xAxisPlaneNode = SCNNode(geometry: xAxisPlane)
        xAxisPlaneNode.position = SCNVector3(x: 0, y: -0.5, z: Float(numberOfFields)/2+0.55)
        xAxisPlaneNode.eulerAngles.x = -Float.pi/2
        xAxisPlaneNode.name="coloredXAxis"
        self.scene!.rootNode.addChildNode(xAxisPlaneNode)
        
        let xAxisDownPlaneNode = SCNNode(geometry: xAxisPlane)
        xAxisDownPlaneNode.position = SCNVector3(x: 0, y: -0.5, z: Float(numberOfFields)/2+0.55)
        xAxisDownPlaneNode.eulerAngles.x = Float.pi/2
        xAxisDownPlaneNode.name="coloredXAxis"
        self.scene!.rootNode.addChildNode(xAxisDownPlaneNode)
        
        let yAxisPlane = SCNPlane(width: 0.9, height: CGFloat(numberOfFields))
        let yAxisPlaneNode = SCNNode(geometry: yAxisPlane)
        yAxisPlaneNode.position = SCNVector3(x: -Float(numberOfFields)/2-0.55, y: -0.5, z: 0)
        yAxisPlaneNode.eulerAngles.x = -Float.pi/2
        yAxisPlaneNode.name="coloredYAxis"
        self.scene!.rootNode.addChildNode(yAxisPlaneNode)
        
        let yAxisDownPlaneNode = SCNNode(geometry: yAxisPlane)
        yAxisDownPlaneNode.position = SCNVector3(x: -Float(numberOfFields)/2-0.55, y: -0.5, z: 0)
        yAxisDownPlaneNode.eulerAngles.x = Float.pi/2
        yAxisDownPlaneNode.name="coloredYAxis"
        self.scene!.rootNode.addChildNode(yAxisDownPlaneNode)
        
        
        //create axes numbers
        for x in 1 ... numberOfFields{
            let xText = SCNText(string: "\(x)", extrusionDepth: 0.02)
            xText.font = UIFont(name: "Menlo", size: 1.0/3)
            xText.containerFrame = CGRect(x: 0, y: 0.5, width: 1, height: 1.0/3)
            xText.isWrapped = true
            xText.alignmentMode = CATextLayerAlignmentMode.center.rawValue
            let xTextNode = SCNNode(geometry: xText)
            xTextNode.name = "x axis number"
            xTextNode.position = SCNVector3(x: Float(x)-Float(numberOfFields)/2-1, y: -0.5, z: Float(numberOfFields)/2+1.5)
            xTextNode.eulerAngles.x = -Float.pi/2
            self.scene!.rootNode.addChildNode(xTextNode)
        }
        
        for y in 1 ... numberOfFields{
            let yText = SCNText(string: "\(y)", extrusionDepth: 0.02)
            yText.font=UIFont(name: "Menlo", size: 1.0/3)
            yText.containerFrame=CGRect(x: 0, y: 0.5, width: 1, height: 1.0/3)
            yText.isWrapped = true
            yText.alignmentMode = CATextLayerAlignmentMode.center.rawValue
            let yTextNode = SCNNode(geometry: yText)
            yTextNode.name = "y axis number"
            yTextNode.position = SCNVector3(x: -Float(numberOfFields)/2-1.05, y: -0.5, z: Float(numberOfFields)/2-Float(y-1)+0.5)
            yTextNode.eulerAngles.x = -Float.pi/2
            self.scene!.rootNode.addChildNode(yTextNode)
        }
        

        //create x curtain
        let xOuterCurtainNode = SCNNode()
        xOuterCurtainNode.position = SCNVector3(x: 0, y: 14.5, z: -Float(numberOfFields)/2-0.99)
        xOuterCurtainNode.eulerAngles.y = Float.pi
        xOuterCurtainNode.name="xOuterCurtain"
        xOuterCurtainNode.categoryBitMask = HitTestType.notDetectable.rawValue

        let xOuterCurtainPlane = SCNPlane(width: CGFloat(numberOfFields), height: 30)
        let xOuterCurtainPlaneNode = SCNNode(geometry: xOuterCurtainPlane)
        xOuterCurtainPlaneNode.name = "notDeletable"
        xOuterCurtainPlaneNode.categoryBitMask = HitTestType.notDetectable.rawValue
        xOuterCurtainNode.addChildNode(xOuterCurtainPlaneNode)

        self.scene!.rootNode.addChildNode(xOuterCurtainNode)
                
        let xInnerCurtainNode = SCNNode()
        xInnerCurtainNode.position = SCNVector3(x: 0, y: 14.5, z: -Float(numberOfFields)/2-1.01)
        xInnerCurtainNode.name="xInnerCurtain"
        xInnerCurtainNode.categoryBitMask = HitTestType.notDetectable.rawValue
        
        let xInnerCurtainPlane = SCNPlane(width: CGFloat(numberOfFields), height: 30)
        let xInnerCurtainPlaneNode = SCNNode(geometry: xInnerCurtainPlane)
        xInnerCurtainPlaneNode.opacity = 0.9
        xInnerCurtainPlaneNode.name = "notDeletable"
        xInnerCurtainPlaneNode.categoryBitMask = HitTestType.notDetectable.rawValue
        xInnerCurtainNode.addChildNode(xInnerCurtainPlaneNode)

        self.scene!.rootNode.addChildNode(xInnerCurtainNode)
        
        
        //create y curtain
        let yOuterCurtainNode = SCNNode()
        yOuterCurtainNode.position = SCNVector3(x: Float(numberOfFields)/2+0.99, y: 14.5, z: 0)
        yOuterCurtainNode.eulerAngles.y = Float.pi/2
        yOuterCurtainNode.name="yOuterCurtain"
        yOuterCurtainNode.categoryBitMask = HitTestType.notDetectable.rawValue
        
        let yOuterCurtainPlaneNode = SCNNode(geometry: xOuterCurtainPlane)
        yOuterCurtainPlaneNode.name = "notDeletable"
        yOuterCurtainPlaneNode.categoryBitMask = HitTestType.notDetectable.rawValue
        yOuterCurtainNode.addChildNode(yOuterCurtainPlaneNode)
        self.scene!.rootNode.addChildNode(yOuterCurtainNode)
        
        let yInnerCurtainNode = SCNNode()
        yInnerCurtainNode.position = SCNVector3(x: Float(numberOfFields)/2+1.01, y: 14.5, z: 0)
        yInnerCurtainNode.eulerAngles.y = -Float.pi/2
        yInnerCurtainNode.name="yInnerCurtain"
        yInnerCurtainNode.categoryBitMask = HitTestType.notDetectable.rawValue
        
        let yInnerCurtainPlane = SCNPlane(width: CGFloat(numberOfFields), height: 30)
        let yInnerCurtainPlaneNode = SCNNode(geometry: yInnerCurtainPlane)
        yInnerCurtainPlaneNode.opacity = 0.9
        yInnerCurtainPlaneNode.name = "notDeletable"
        yInnerCurtainPlaneNode.categoryBitMask = HitTestType.notDetectable.rawValue
        yInnerCurtainNode.addChildNode(yInnerCurtainPlaneNode)

        self.scene!.rootNode.addChildNode(yInnerCurtainNode)
        
        
        //create floor curtain
        let floorCurtainNode = SCNNode()
        floorCurtainNode.position = SCNVector3(x: -0.5, y: -0.5, z: 0.5)
        floorCurtainNode.name="floorCurtain"
        floorCurtainNode.eulerAngles.x = -Float.pi/2
        floorCurtainNode.categoryBitMask = HitTestType.notDetectable.rawValue
        self.scene!.rootNode.addChildNode(floorCurtainNode)
        
        
        //create ring
        let ring = SCNTorus(ringRadius: CGFloat(numberOfFields)+0.5, pipeRadius: 0.05)
        let ringNode = SCNNode(geometry: ring)
        ringNode.position = SCNVector3(x: 0, y: 0, z: 0)
        ringNode.name = "ring"
        //        self.scene!.rootNode.addChildNode(ringNode)
        
        
        let viewSphere = SCNSphere(radius: 0.25)
        
        let rightViewSphereNode = SCNNode(geometry: viewSphere)
        rightViewSphereNode.name = "rightViewSphere"
        rightViewSphereNode.position = SCNVector3(x: Float(numberOfFields)+0.5, y: 0, z: 0)
        ringNode.addChildNode(rightViewSphereNode)

        let leftViewSphereNode = SCNNode(geometry: viewSphere)
        leftViewSphereNode.name = "leftViewSphere"
        leftViewSphereNode.position = SCNVector3(x: -Float(numberOfFields)-0.5, y: 0, z: 0)
        ringNode.addChildNode(leftViewSphereNode)

        let backViewSphereNode = SCNNode(geometry: viewSphere)
        backViewSphereNode.name = "backViewSphere"
        backViewSphereNode.position = SCNVector3(x: 0, y: 0, z: -Float(numberOfFields)-0.5)
        ringNode.addChildNode(backViewSphereNode)

        let frontViewSphereNode = SCNNode(geometry: viewSphere)
        frontViewSphereNode.name = "frontViewSphere"
        frontViewSphereNode.position = SCNVector3(x: 0, y: 0, z: Float(numberOfFields)+0.5)
        ringNode.addChildNode(frontViewSphereNode)

        
        renewCurtains()
    }
    
    
    
    
    func reloadContent(newNumberOfFields: Int, newTypesOfCubes: Int){
        
        //if number of fields changes
        if(numberOfFields != newNumberOfFields){
            numberOfFields = newNumberOfFields
            createContent()
            removeAllCubes()
        }
        
        //if type of cubes changes
        if(typeOfCubes != newTypesOfCubes){
            typeOfCubes = newTypesOfCubes
            removeAllCubes()
        }
        
        
        //renew visibility of all elements
        
        for node in self.scene!.rootNode.childNodes.filter({$0.name == "coloredXAxis" || $0.name == "coloredYAxis"}){
            node.opacity = coloredAxesAreEnabled ? 1 : 0
        }
        
        for node in self.scene!.rootNode.childNodes.filter({$0.name == "x axis number" || $0.name == "y axis number"}){
            node.opacity = axesNumbersAreEnabled ? 1 : 0
        }
        
        
        for node in self.scene!.rootNode.childNodes.filter({$0.name == "xOuterCurtain"}){
            node.opacity = xCurtainIsVisible ? 0.5 : 0
        }
        for node in self.scene!.rootNode.childNodes.filter({$0.name == "xInnerCurtain"}){
            node.opacity = xCurtainIsVisible ? 1 : 0
        }
        for node in self.scene!.rootNode.childNodes.filter({$0.name == "yOuterCurtain"}){
            node.opacity = yCurtainIsVisible ? 0.5 : 0
        }
        for node in self.scene!.rootNode.childNodes.filter({$0.name == "yInnerCurtain"}){
            node.opacity = yCurtainIsVisible ? 1 : 0
        }
        for node in self.scene!.rootNode.childNodes.filter({$0.name == "floorCurtain"}){
            node.opacity = floorIsVisible ? 1 : 0
        }
        
        
        renewColors()
    }

    
    //show or hide multi view axis
    func showMultiViewAxis(){
        multiViewAxisNode.opacity = 1
    }
    func hideMultiViewAxis(){
        multiViewAxisNode.opacity = 0
    }
    
    
    //show or hide isometric axis
    func showIsometricAxis(){
        isometricAxisNode.opacity = 1
    }
    func hideIsometricAxis(){
        isometricAxisNode.opacity = 0
    }
    
    
    //filter a set of unique cubes visible on curtain, depending on direction
    enum ShadowDirection{
        case back, right, bottom
    }
    func filteredCubes(direction: ShadowDirection) -> Set<Cube>{
        var set : Set<Cube> = []
        switch direction {
        case .back:
            for cube in setOfCubes{
                if(set.filter({$0.x == cube.x && $0.z == cube.z && cube.z < 50}).isEmpty){
                    set.insert(cube)
                }
            }
        case .right:
            for cube in setOfCubes{
                if(set.filter({$0.y == cube.y && $0.z == cube.z && cube.z < 50}).isEmpty){
                    set.insert(cube)
                }
            }
        case .bottom:
            for cube in setOfCubes{
                if(set.filter({$0.y == cube.y && $0.x == cube.x}).isEmpty){
                    set.insert(cube)
                }
            }
        }
        set = set.filter({$0.z != 0})
        return set
    }

    
    //renew shadows on curtains (remove all shadows and add all filtered shadows)
    func renewCurtains(){
        renewXCurtain()
        renewYCurtain()
        renewFloorCurtain()
        renewColors()
        
        //show information label, if some cube is outside the grid
        informationLabel.alpha = 0
        if(xCurtainIsVisible || yCurtainIsVisible){
            for cube in setOfCubes{
                if((cube.x <= 0 || cube.x>numberOfFields || cube.y <= 0 || cube.y>numberOfFields) && cube.z != 0){
                    informationLabel.alpha = 1
                }
            }
        }

        
    }
    
    func renewXCurtain(){
        for node in self.scene!.rootNode.childNodes.filter({$0.name == "xInnerCurtain"}){
            for child in node.childNodes{
                if(child.name != "notDeletable"){
                    child.removeFromParentNode()
                }
            }
            for cube in filteredCubes(direction: .back){
                let shade = SCNPlane(width: 1, height: 1)
                let shadeNode = SCNNode(geometry: shade)
                shadeNode.categoryBitMask = HitTestType.notDetectable.rawValue
                shadeNode.position = SCNVector3(x: Float(cube.x)-Float(numberOfFields)/2-0.5, y: -14.5+Float(cube.z-1), z: 0.01)
                shadeNode.name = "shade"
                if(cube.x > 0 && cube.x<=numberOfFields && cube.y > 0 && cube.y<=numberOfFields && cube.z != 0){
                    node.addChildNode(shadeNode)
                }
            }
        }
        for node in self.scene!.rootNode.childNodes.filter({$0.name == "xOuterCurtain"}){
            for child in node.childNodes{
                if(child.name != "notDeletable"){
                    child.removeFromParentNode()
                }
            }
            for cube in filteredCubes(direction: .back){
                let shade = SCNPlane(width: 1, height: 1)
                let shadeNode = SCNNode(geometry: shade)
                shadeNode.categoryBitMask = HitTestType.notDetectable.rawValue
                shadeNode.position = SCNVector3(x: Float(numberOfFields)/2-Float(cube.x)+0.5, y: -14.5+Float(cube.z-1), z: 0.01)
                shadeNode.renderingOrder = 4
                shadeNode.name = "shade"
                if(cube.x > 0 && cube.x<=numberOfFields && cube.y > 0 && cube.y<=numberOfFields && cube.z != 0){
                    node.addChildNode(shadeNode)
                }
            }
        }
    }

    func renewYCurtain(){
        for node in self.scene!.rootNode.childNodes.filter({$0.name == "yInnerCurtain"}){
            for child in node.childNodes{
                if(child.name != "notDeletable"){
                    child.removeFromParentNode()
                }
            }
            for cube in filteredCubes(direction: .right){
                let shade = SCNPlane(width: 1, height: 1)
                let shadeNode = SCNNode(geometry: shade)
                shadeNode.categoryBitMask = HitTestType.notDetectable.rawValue
                shadeNode.position = SCNVector3(x: -Float(cube.y)+Float(numberOfFields)/2+0.5, y: -14.5+Float(cube.z-1), z: 0.01)
                shadeNode.name = "shade"
                if(cube.x > 0 && cube.x<=numberOfFields && cube.y > 0 && cube.y<=numberOfFields && cube.z != 0){
                    node.addChildNode(shadeNode)
                }
            }
        }
        for node in self.scene!.rootNode.childNodes.filter({$0.name == "yOuterCurtain"}){
            for child in node.childNodes{
                if(child.name != "notDeletable"){
                    child.removeFromParentNode()
                }
            }
            for cube in filteredCubes(direction: .right){
                let shade = SCNPlane(width: 1, height: 1)
                let shadeNode = SCNNode(geometry: shade)
                shadeNode.categoryBitMask = HitTestType.notDetectable.rawValue
                shadeNode.position = SCNVector3(x: Float(cube.y)-Float(numberOfFields)/2-0.5, y: -14.5+Float(cube.z-1), z: 0.01)
                shadeNode.renderingOrder = 4
                shadeNode.name = "shade"
                if(cube.x > 0 && cube.x<=numberOfFields && cube.y > 0 && cube.y<=numberOfFields && cube.z != 0){
                    node.addChildNode(shadeNode)
                }
            }
        }
    }
    
    
    func renewFloorCurtain(){
        for node in self.scene!.rootNode.childNodes.filter({$0.name == "floorCurtain"}){
            for child in node.childNodes{
                child.removeFromParentNode()
            }
            for cube in filteredCubes(direction: .bottom){
                let shade = SCNPlane(width: 1, height: 1)
                let shadeNode = SCNNode(geometry: shade)
                shadeNode.categoryBitMask = HitTestType.notDetectable.rawValue
                shadeNode.position = SCNVector3(x: -Float(numberOfFields)/2+Float(cube.x), y: -Float(numberOfFields)/2+Float(cube.y), z: 0.01)
                shadeNode.name = "shade"
                if(cube.x > 0 && cube.x<=numberOfFields && cube.y > 0 && cube.y<=numberOfFields && cube.z != 0){
                    node.addChildNode(shadeNode)
                }
                let reversedShade = SCNPlane(width: 1, height: 1)
                let reversedShadeNode = SCNNode(geometry: reversedShade)
                reversedShadeNode.categoryBitMask = HitTestType.notDetectable.rawValue
                reversedShadeNode.position = SCNVector3(x: -Float(numberOfFields)/2+Float(cube.x), y: -Float(numberOfFields)/2+Float(cube.y), z: -0.02)
                reversedShadeNode.renderingOrder = 4
                reversedShadeNode.eulerAngles.x = .pi
                reversedShadeNode.name = "shade"
                reversedShadeNode.opacity = 0.9
                if(cube.x > 0 && cube.x<=numberOfFields && cube.y > 0 && cube.y<=numberOfFields && cube.z != 0){
                    node.addChildNode(reversedShadeNode)
                }
            }
        }
    }
    
    
    //renew all colors and textures
    func renewColors(){

        for cubeNode in setOfCubesNodes{
            cubeNode.updateColor()
        }

        for node in scene!.rootNode.childNodes.map({$0 as? SceneViewFloor}){
            node?.updateColor()
        }
        for node in scene!.rootNode.childNodes.map({$0 as? SceneViewFlippedFloor}){
            node?.updateColor()
        }

        let shadowMaterial = SCNMaterial()
        shadowMaterial.diffuse.contents = shadowColor

        for node in self.scene!.rootNode.childNodes.filter({$0.name == "xInnerCurtain" || $0.name == "xOuterCurtain" || $0.name == "yInnerCurtain" || $0.name == "yOuterCurtain" || $0.name == "floorCurtain"}){
            for childNode in node.childNodes.filter({$0.name == "shade"}){
                childNode.geometry!.materials = [shadowMaterial]
            }
        }

        let greenMaterial = SCNMaterial()
        greenMaterial.diffuse.contents = xAxisColor
        let blueMaterial = SCNMaterial()
        blueMaterial.diffuse.contents = yAxisColor
        let backgroundMaterial = SCNMaterial()
        backgroundMaterial.diffuse.contents = systemBackgroundColor
        
        for node in self.scene!.rootNode.childNodes.filter({$0.name == "coloredXAxis"}){
            node.geometry!.materials = [greenMaterial]
        }
        for node in self.scene!.rootNode.childNodes.filter({$0.name == "coloredYAxis"}){
            node.geometry!.materials = [blueMaterial]
        }
        for node in self.scene!.rootNode.childNodes.filter({$0.name == "x axis number"}){
            node.geometry!.materials = coloredAxesAreEnabled ? [backgroundMaterial] : [greenMaterial]
        }
        for node in self.scene!.rootNode.childNodes.filter({$0.name == "y axis number"}){
            node.geometry!.materials = coloredAxesAreEnabled ? [backgroundMaterial] : [blueMaterial]
        }
        
        let curtainMaterial = SCNMaterial()
        curtainMaterial.diffuse.contents = lightFloorColor

        for node in self.scene!.rootNode.childNodes.filter({$0.name == "xInnerCurtain" || $0.name == "xOuterCurtain" || $0.name == "yInnerCurtain" || $0.name == "yOuterCurtain"}){
            for childNode in node.childNodes.filter({$0.name == "notDeletable"}){
                childNode.geometry!.materials = [curtainMaterial]
            }
        }

        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = specialElementColor
        for node in self.scene!.rootNode.childNodes.filter({$0.name == "axis" || $0.name == "isoaxis" || $0.name == "rightViewSphere" || $0.name == "leftViewSphere" || $0.name == "frontViewSphere" || $0.name == "backViewSphere"}){
            node.geometry!.materials = [redMaterial]
            for childNode in node.childNodes{
                childNode.geometry!.materials = [redMaterial]
            }
        }
        for node in self.scene!.rootNode.childNodes.filter({$0.name == "ring"}){
            for childNode in node.childNodes.filter({$0.name == "rightViewSphere" || $0.name == "leftViewSphere" || $0.name == "frontViewSphere" || $0.name == "backViewSphere"}){
                childNode.geometry!.materials = [redMaterial]
            }
        }
    }
    
    
    //*** NEW CUBE ***//
    
    //tap cube or floor
    @objc func sceneTapped(sender: UITapGestureRecognizer) {
        
        cubeOpacity = 1
        for cubeNode in setOfCubesNodes{
            cubeNode.opacity = 1
        }
        cubesAreVisible = true
        
        let location = sender.location(in: self)
        
        let hitResults = self.hitTest(location, options: [SCNHitTestOption.categoryBitMask: HitTestType.detectable.rawValue])
        
        //if any element is touched
        if let touchedElement = hitResults.first{
            
            //if touched element is a cube
            if let touchedCube = touchedElement.node as? SceneCubeNode, cubesAreVisible == true{
                
                
                switch typeOfCubes {
                    
                //wooden cubes
                case 0:
                    //only on top of wooden cube
                    if(touchedElement.geometryIndex == 4){
                        addCube(x: touchedCube.x, y: touchedCube.y, z: touchedCube.z+1)
                        
                        //add code line
                        addCodeLineWithCreatedCube(x: touchedCube.x, y: touchedCube.y)
                    }
                    
                    
                //stackable or magic cubes
                default:
                    switch touchedElement.geometryIndex {
                    //right of cube
                    case 1:
                        if(touchedCube.x<numberOfFields){
                            addCube(x: touchedCube.x+1, y: touchedCube.y, z: touchedCube.z)
                        }
                    //behind cube
                    case 2:
                        if(touchedCube.y<numberOfFields){
                            addCube(x: touchedCube.x, y: touchedCube.y+1, z: touchedCube.z)
                        }
                    //left of cube
                    case 3:
                        if(touchedCube.x>1){
                            addCube(x: touchedCube.x-1, y: touchedCube.y, z: touchedCube.z)
                        }
                    //on top of cube
                    case 4:
                        addCube(x: touchedCube.x, y: touchedCube.y, z: touchedCube.z+1)
                    //under cube
                    case 5:
                        if(touchedCube.z>1){
                            addCube(x: touchedCube.x, y: touchedCube.y, z: touchedCube.z-1)
                        }
                    //in front of cube
                    default:
                        if(touchedCube.y>1){
                            addCube(x: touchedCube.x, y: touchedCube.y-1, z: touchedCube.z)
                        }
                    }
                }
            }
            
            if(touchedElement.node.name == "rightViewSphere"){
                let action = SCNAction.rotateTo(x: 0, y: .pi/2, z: 0, duration: 1)
                cameraOrbit.runAction(action)
                lightOrbit.runAction(action)
            }
            if(touchedElement.node.name == "backViewSphere"){
                let action = SCNAction.rotateTo(x: 0, y: .pi, z: 0, duration: 1)
                cameraOrbit.runAction(action)
                lightOrbit.runAction(action)
            }
            if(touchedElement.node.name == "leftViewSphere"){
                let action = SCNAction.rotateTo(x: 0, y: -.pi/2, z: 0, duration: 1)
                cameraOrbit.runAction(action)
                lightOrbit.runAction(action)
            }
            if(touchedElement.node.name == "frontViewSphere"){
                let action = SCNAction.rotateTo(x: 2 * .pi, y: 0, z: 0, duration: 1)
                cameraOrbit.runAction(action)
                lightOrbit.runAction(action)
            }
            
            
            /*
            //to create app icon
            for node in scene!.rootNode.childNodes.map({$0 as? SceneViewFloor}){
                node?.opacity = 0
            }
            */

            
            //look for floor or cube in touched node and add a cube
            var tmpResult = touchedElement.node
            var parentIsFloorPlane = Bool(false)
            var touchedFloor : SceneViewFloor!
            
            while(tmpResult.parent != nil){
                tmpResult = tmpResult.parent!
                if(tmpResult is SceneViewFloor){
                    parentIsFloorPlane = true
                    touchedFloor = tmpResult as? SceneViewFloor
                }
            }
            
            if(parentIsFloorPlane && codeIsTracing == false && cubesAreVisible == true){
                
                addCube(x: touchedFloor.x, y: touchedFloor.y, z: 1)
                
                //add code line
                if(typeOfCubes == 0){
                    let structCodeLine = StructCodeLine(identifier: codeView.lastIdentifier(), values: [StructCodeLineValue(isSet: true, value: touchedFloor.x),StructCodeLineValue(isSet: true, value: touchedFloor.y)], lineType: .buildCoordinates, lineNumber: codeView.insertLineNumber)
                    setOfStructCodeLines.insert(structCodeLine)
                    addCodeLineWithCreatedCube(x: touchedFloor.x, y: touchedFloor.y)
                }
            }
        }
    }
    
    
    //code line for added wooden cube
    func addCodeLineWithCreatedCube(x: Int, y: Int){
        codeView.insertLineNumber = setOfCodeLines.count+1
        let newLine = codeView.addCodeLine(type: .buildCoordinates)
        newLine.listOfValues[0].value = x
        newLine.listOfValues[0].valueIsSet = true
        newLine.listOfValues[1].value = y
        newLine.listOfValues[1].valueIsSet = true
        newLine.renewCodeLine()
        codeView.showAllCubes()
    }

    //code line for removed wooden cube
    func addCodeLineWithRemovedCube(x: Int, y: Int){
        let newLine = codeView.addCodeLine(type: .removeCoordinates)
        newLine.listOfValues[0].value = x
        newLine.listOfValues[0].valueIsSet = true
        newLine.listOfValues[1].value = y
        newLine.listOfValues[1].valueIsSet = true
        newLine.renewCodeLine()
        codeView.showAllCubes()
    }

    
    
    
    //calc height of cube
    func heightNumberByField(x: Int, y: Int) -> Int{
        var height = Int(0)
        for cube in setOfCubes{
            if(cube.x == x && cube.y==y){
                height += 1
            }
        }
        if(x == -1 && y == -1){
            height -= 1
        }
        return height
    }
    
    
    //add cube
    func addCube(x: Int, y: Int, z: Int){

        //add so set of cubes
        setOfCubes.insert(Cube(x: x, y: y, z: z, visited: false))
        
        //"draw" cube
        let cubeNode = SceneCubeNode()
        cubeNode.categoryBitMask = HitTestType.detectable.rawValue
        cubeNode.x = x
        cubeNode.y = y
        cubeNode.z = z
        cubeNode.position=SCNVector3(x: Float(x)-Float(numberOfFields)/2-0.5, y: Float(z-1), z: Float(numberOfFields)/2-Float(y)+0.5);
        self.scene!.rootNode.addChildNode(cubeNode)
        setOfCubesNodes.insert(cubeNode)

        if(typeOfCubes != 0){
            renewOtherViews()
        }

    }
    
    
    
    //*** REMOVE A CUBE ***//
    
    //long press a cube
    @objc func sceneLongTapped(sender: UILongPressGestureRecognizer) {
        
        let location = sender.location(in: self)
        let mask = HitTestType.detectable.rawValue
        let hitResults = self.hitTest(location, options: [SCNHitTestOption.categoryBitMask: mask])
        
        if hitResults.count > 0 {
            let result = hitResults[0]

            //look for cube in touched node and remove it
            var listOfParents : [SCNNode] = []
            var tmpResult = result.node
            while(tmpResult.parent != nil){
                listOfParents += [tmpResult]
                tmpResult = tmpResult.parent!
            }
            
            if let touchedNode = listOfParents.last{
                
                if(touchedNode is SceneCubeNode && sender.state == .began){
                    
                    let touchedCubeNode = touchedNode as! SceneCubeNode
                    
                    switch typeOfCubes{
                    //wooden cube: remove if is on top
                    case 0:
                        if(heightNumberByField(x: touchedCubeNode.x, y: touchedCubeNode.y) == touchedCubeNode.z){

                            removeCube(cubeNode: touchedCubeNode)

                            addCodeLineWithRemovedCube(x: touchedCubeNode.x, y: touchedCubeNode.y)
                        }
                        
                    //magic cube
                    case 2:
                        removeCube(cubeNode: touchedCubeNode)
                        
                    //stackable cube: remove, if remain cubes are connected to floor
                    default:
                        //for deep search, create "removed" cube
                        let touchedCube = Cube(x: touchedCubeNode.x, y: touchedCubeNode.y, z: touchedCubeNode.z, visited: false)
                        var reducedSetOfCubes = setOfCubes
                        reducedSetOfCubes.remove(touchedCube)
                        

                        //do deep search for every neighbor of touched cube
                        var floorIsReachableFromAllNeighbors = Bool(true)

                        for anyNeighbor in reducedSetOfCubes.filter({areNeighbors(firstCube: $0, secondCube: touchedCube)}){
                            if(isFloorReachable(testSetOfCubes: deepSearch(testCube: anyNeighbor, testSetOfCubes: reducedSetOfCubes)) == false){
                                floorIsReachableFromAllNeighbors = false
                            }
                        }
                        
                        //remove cube, if floor is reachable by neighbor cubes
                        if(floorIsReachableFromAllNeighbors == true){
                            removeCube(cubeNode: touchedCubeNode)
                        }
                    }
                }
            }
        }
    }
    
    
    //to check if cubes are neighbors
    func areNeighbors(firstCube: Cube, secondCube: Cube) -> Bool {
        var result = Bool(false)
        let proof1 = abs(firstCube.y - secondCube.y)+abs(firstCube.z - secondCube.z)
        if((firstCube.x == secondCube.x) && (proof1 == 1)){
            result = true
        }
        let proof2 = abs(firstCube.x - secondCube.x)+abs(firstCube.z - secondCube.z)
        if((firstCube.y == secondCube.y) && (proof2 == 1)){
            result = true
        }
        let proof3 = abs(firstCube.y - secondCube.y)+abs(firstCube.x - secondCube.x)
        if((firstCube.z == secondCube.z) && (proof3 == 1)){
            result = true
        }
        if((firstCube.z == 1 && secondCube.z==0) || (firstCube.z == 0 && secondCube.z==1)){
            result = true
        }
        return result
    }

    //deep search
    func deepSearch(testCube: Cube, testSetOfCubes: Set<Cube>) -> Set<Cube>{
        
        var tmpSetOfCubes = testSetOfCubes
        
        let visitedTestCube = Cube(x: testCube.x, y: testCube.y, z: testCube.z, visited: true)

        tmpSetOfCubes.remove(testCube)
        tmpSetOfCubes.insert(visitedTestCube)
        //order is important, because hash in setOfCubes only looks about position of cubes, not about visited value!
        
        for anyCube in testSetOfCubes{
            let visitedAnyCube = Cube(x: anyCube.x, y: anyCube.y, z: anyCube.z, visited: true)
            if(areNeighbors(firstCube: testCube, secondCube: anyCube)){
                for oldAnyCube in tmpSetOfCubes{
                    if(oldAnyCube == visitedAnyCube && oldAnyCube.visited == false){
                        tmpSetOfCubes = deepSearch(testCube: visitedAnyCube,  testSetOfCubes: tmpSetOfCubes)
                    }
                }
            }
        }
        return tmpSetOfCubes
    }
    
    
    //check if floor is reachable
    func isFloorReachable(testSetOfCubes: Set<Cube>) -> Bool{
        return !testSetOfCubes.filter({$0.z == 0 && $0.visited == true}).isEmpty
    }
    
    
    //remove a cube and renew all views
    func removeCube(cubeNode: SceneCubeNode){
        let cube = Cube(x: cubeNode.x, y: cubeNode.y, z: cubeNode.z, visited: false)
        setOfCubes.remove(cube)
        cubeNode.removeFromParentNode()
        setOfCubesNodes.remove(cubeNode)
        
        if(typeOfCubes != 0){
            renewOtherViews()
        }
    }
    
    func renewOtherViews(){
        //renew shadows on curtains
        renewCurtains()

        //renew other views
        planView.updateFieldNumbers()
        
        if let viewController = sceneView.window?.rootViewController as? ViewController{
            viewController.renewVisibleView(index: viewController.rightViewSegmentControl.selectedSegmentIndex)
        }
    }
    
    
    //remove all cubes
    func removeAllCubes(){
        
        //disable code tracing
        if(typeOfCubes == 0 && codeIsTracing){
            codeView.endCodeTracing()
        }

        //remeove every "drawn" cubes
        for cubeNode in setOfCubesNodes{
            removeCube(cubeNode: cubeNode)
        }

        //remove every code line
        for line in setOfCodeLines{
            setOfCodeLines.remove(line)
            line.removeFromSuperview()
        }
        //renew code settings
        codeView.insertLineNumber = 1
        codeView.insertCodeLineNumberIndicator.center.y = displayPositionByLineNumber(codeView.insertLineNumber, depth: 0).y+5
        codeView.updateLineNumbers()
        codeView.renewTextViewContentHeight()

        setOfStructCodeLines = []
        
        renewOtherViews()
    }
    
    
    
    //*** CHANGE VIEW ***//
        
    //rotate: change angles of camera orbit
    var lastHeightRatio: Float!
    var lastWidthRatio: Float!
    var lastLightHeightRatio: Float!
    var lastLightWidthRatio: Float!

    @objc func handlePanGesture(sender: UIPanGestureRecognizer) {
        if (sender.state == .began) {
            lastHeightRatio = -cameraOrbit.eulerAngles.x/Float.pi
            lastWidthRatio = -cameraOrbit.eulerAngles.y/Float.pi/2
            lastLightHeightRatio = -lightOrbit.eulerAngles.x/Float.pi
            lastLightWidthRatio = -lightOrbit.eulerAngles.y/Float.pi/2
        }
        let translation = sender.translation(in: sender.view!)
        let widthRatio = Float(translation.x) / Float(sender.view!.frame.size.width) + lastWidthRatio
        let heightRatio = Float(translation.y) / Float(sender.view!.frame.size.height) + lastHeightRatio
        self.cameraOrbit.eulerAngles.y = -2 * Float.pi * widthRatio
        self.cameraOrbit.eulerAngles.x = -Float.pi * heightRatio

        //        if(self.cameraOrbit.eulerAngles.y < 0){
        //            self.cameraOrbit.eulerAngles.y += 2 * .pi
        //        }
        //        if(self.cameraOrbit.eulerAngles.x < 0){
        //            self.cameraOrbit.eulerAngles.x += 2 * .pi
        //        }

        let lightWidthRatio = Float(translation.x) / Float(sender.view!.frame.size.width) + lastLightWidthRatio
        let lightHeightRatio = Float(translation.y) / Float(sender.view!.frame.size.height) + lastLightHeightRatio
        //        self.lightOrbit.eulerAngles.y = -2 * Float.pi * lightWidthRatio
        //        self.lightOrbit.eulerAngles.x = -Float.pi * lightHeightRatio

        if (sender.state == .ended) {
            lastWidthRatio = widthRatio.truncatingRemainder(dividingBy: 1)
            lastHeightRatio = heightRatio.truncatingRemainder(dividingBy: 1)
            lastLightWidthRatio = lightWidthRatio.truncatingRemainder(dividingBy: 1)
            lastLightHeightRatio = lightHeightRatio.truncatingRemainder(dividingBy: 1)
        }
    }
    
    //zoom: change distance of camera
    var lastZPos : Float!
    @objc func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        if (sender.state == .began) {
            lastZPos = self.cameraNode.position.z
        }
        let scale = Float(sender.scale)
        self.cameraNode.position.z = lastZPos/scale
        if(self.cameraNode.position.z<5){
            self.cameraNode.position.z=5
        }
        if(self.cameraNode.position.z>50){
            self.cameraNode.position.z=50
        }
        if (sender.state == .ended) {
            lastZPos = self.cameraNode.position.z
        }
    }

}
