//
//  PreferencesViewController.swift
//  Cubeling
//
//  Created by Heiko Etzold on 16.11.19.
//  MIT License
//


import UIKit

class PreferencesViewController: UIViewController {

    @IBOutlet weak var xCurtainSwitch: UISwitch!
    @IBOutlet weak var yCurtainSwitch: UISwitch!
    @IBOutlet weak var floorSwitch: UISwitch!
    @IBOutlet weak var cubeImageView: UIImageView!
    @IBOutlet weak var cubeVisibilitySlider: UISlider!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //change switch elements
        xCurtainSwitch.setOn(sceneView.xCurtainIsVisible, animated: false)
        yCurtainSwitch.setOn(sceneView.yCurtainIsVisible, animated: false)
        floorSwitch.setOn(sceneView.floorIsVisible, animated: false)
        cubeVisibilitySlider.setValue(sceneView.cubeOpacity, animated: false)
        
        lightSegmentControl.selectedSegmentIndex = lightMode

        //change image of cube
        changeCubeImage()
    }

    func changeCubeImage(){
        switch lightMode{
        case 0:
            switch typeOfCubes {
            case 1:
                cubeImageView.image = UIImage(named: "stackableCube")
            case 2:
                cubeImageView.image = UIImage(named: "magicCube")
            default:
                cubeImageView.image = UIImage(named: "woodenCube")
            }
        case 1:
            switch typeOfCubes {
            case 1:
                cubeImageView.image = UIImage(named: "stackableOutlineCube")
            case 2:
                cubeImageView.image = UIImage(named: "magicOutlineCube")
            default:
                cubeImageView.image = UIImage(named: "woodenOutlineCube")
            }
        default:
            cubeImageView.image = UIImage(named: "nightCube")
        }
    }
    
    //when x curtain switch is changed
    @IBAction func tapXCurtainSwitch(_ sender: UISwitch) {
        changeXCurtain(isVisible: sender.isOn)
    }
    func changeXCurtain(isVisible: Bool){
        sceneView.xCurtainIsVisible = isVisible
        sceneView.reloadContent(newNumberOfFields: numberOfFields, newTypesOfCubes: typeOfCubes)
        sceneView.renewCurtains()
    }
    
    
    //when y curtain switch is changed
    @IBAction func tapYCurtainSwitch(_ sender: UISwitch) {
        changeYCurtain(isVisible: sender.isOn)
    }
    func changeYCurtain(isVisible: Bool){
        sceneView.yCurtainIsVisible = isVisible
        sceneView.reloadContent(newNumberOfFields: numberOfFields, newTypesOfCubes: typeOfCubes)
        sceneView.renewCurtains()
    }
    
    
    //when floor curtain switch is changed
    @IBAction func tapFloorSwitch(_ sender: UISwitch) {
        changeFloor(isVisible: sender.isOn)

    }
    func changeFloor(isVisible: Bool){
        sceneView.floorIsVisible = isVisible
        sceneView.reloadContent(newNumberOfFields: numberOfFields, newTypesOfCubes: typeOfCubes)
    }
    

    //when cube opacity is changed
    @IBAction func moveCubeVisibilitySlider(_ sender: UISlider) {
        changeCubeVisibility(opacity: sender.value)
    }
    func changeCubeVisibility(opacity: Float){
        sceneView.cubesAreVisible = (opacity == 1)
        sceneView.cubeOpacity = opacity
        for cubeNode in sceneView.setOfCubesNodes{
            cubeNode.opacity = CGFloat(opacity)
        }
    }
    
    
    @IBOutlet weak var lightSegmentControl: UISegmentedControl!
    @IBAction func changeLight(_ sender: UISegmentedControl) {
        lightMode = sender.selectedSegmentIndex

        cubeVisibilitySlider.setValue(1, animated: true)
        changeCubeImage()
        
        var newSetOfCubeNodes : Set<SceneCubeNode> = []
        
        for cubeNode in sceneView.setOfCubesNodes{
            let newCubeNode = SceneCubeNode()
            newCubeNode.position = cubeNode.position
            newCubeNode.x = cubeNode.x
            newCubeNode.y = cubeNode.y
            newCubeNode.z = cubeNode.z
            cubeNode.removeFromParentNode()
            sceneView.setOfCubesNodes.remove(cubeNode)
            sceneView.scene!.rootNode.addChildNode(newCubeNode)
            newSetOfCubeNodes.insert(newCubeNode)
        }
        sceneView.setOfCubesNodes = newSetOfCubeNodes
        sceneView.renewCurtains()
        multiView.updateShadows()
        
        for cube in cavalierView.listOfCavalierCubes{
            cube.removeFromSuperview()
        }
        cavalierView.listOfCavalierCubes = []
        cavalierView.renewContent()
        cavalierView.updateCavalierCubes()

        
        for cube in isometricView.listOfIsometricCubes{
            cube.removeFromSuperview()
        }
        isometricView.listOfIsometricCubes = []
        isometricView.renewContent()
        isometricView.updateCubes()
    }
    
    
}
