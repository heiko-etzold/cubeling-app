//
//  ViewController.swift
//  Cubeling
//
//  Created by Heiko Etzold on 06.08.15.
//  MIT License
//


import UIKit
import SceneKit
import Combine



class ViewController: UIViewController, UIPopoverPresentationControllerDelegate, UIDocumentPickerDelegate {

    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var leftViewSegmentControl: UISegmentedControl!
    @IBOutlet weak var leftViewSwitch: UISwitch!

    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var rightViewSegmentControl: UISegmentedControl!
    @IBOutlet weak var rightViewSwitch: UISwitch!
    
    @IBOutlet weak var organizeButton: UIBarButtonItem!
    
    let sceneViewContainer = UIView()

    #if targetEnvironment(macCatalyst)
    var typeOfCubeSubscriber: AnyCancellable?
    var numberOfCubesSubscriber: AnyCancellable?
    var coloredLinesSubscriber: AnyCancellable?
    var numberedLinesSubscriber: AnyCancellable?
    var loopsSubscriber: AnyCancellable?
    var variablesSubscriber: AnyCancellable?
    #endif

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftView.layoutIfNeeded()
        rightView.layoutIfNeeded()

        leftView.clipsToBounds = true
        rightView.clipsToBounds = true
        
        viewSafeAreaInsetsDidChange()
        
        
        //add scene view
        sceneView = SceneView(frame: CGRect.zero, options: nil)
        sceneViewContainer.addSubview(sceneView)

        if(UIDevice.current.userInterfaceIdiom == .pad){
            //button for manual
            let infoButton = UIButton(type: .system)
            infoButton.translatesAutoresizingMaskIntoConstraints = false
            sceneViewContainer.addSubview(infoButton)

            if #available(iOS 13.4, *) {
                infoButton.isPointerInteractionEnabled = true
            }
            
            if #available(iOS 13.0, *) {
                infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
                infoButton.sizeToFit()
            } else {
                infoButton.setImage(UIImage(named: "infoCircle"), for: .normal)
                infoButton.imageEdgeInsets = .init(top: 2, left: 2, bottom: 2, right: 2)
                infoButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
                infoButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
            }
            infoButton.addTarget(self, action: #selector(self.popoverInfo), for: .touchUpInside)
            infoButton.leftAnchor.constraint(equalTo: sceneViewContainer.leftAnchor, constant: 20).isActive = true
            infoButton.bottomAnchor.constraint(equalTo: sceneViewContainer.bottomAnchor, constant: -15).isActive = true
            
            //button for preferences
            let preferencesButton = UIButton(type: .system)
            preferencesButton.translatesAutoresizingMaskIntoConstraints = false
            sceneViewContainer.addSubview(preferencesButton)

            if #available(iOS 13.4, *) {
                preferencesButton.isPointerInteractionEnabled = true
            }
            if #available(iOS 13.0, *) {
                preferencesButton.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
                preferencesButton.sizeToFit()
            } else {
                preferencesButton.setImage(UIImage(named: "ellipsisCircle"), for: .normal)
                preferencesButton.imageEdgeInsets = .init(top: 2, left: 2, bottom: 2, right: 2)
                preferencesButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
                preferencesButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
            }
            preferencesButton.addTarget(self, action: #selector(popoverPreferences), for: .touchUpInside)
            preferencesButton.leftAnchor.constraint(equalTo: infoButton.rightAnchor, constant: 10).isActive = true
            preferencesButton.bottomAnchor.constraint(equalTo: infoButton.bottomAnchor).isActive = true
        }

        leftView.addSubview(sceneViewContainer)
        sceneViewContainer.translatesAutoresizingMaskIntoConstraints = false
        sceneViewContainer.leftAnchor.constraint(equalTo: leftView.leftAnchor).isActive = true
        sceneViewContainer.topAnchor.constraint(equalTo: leftView.topAnchor).isActive = true
        sceneViewContainer.rightAnchor.constraint(equalTo: leftView.rightAnchor).isActive = true
        sceneViewContainer.bottomAnchor.constraint(equalTo: leftView.bottomAnchor).isActive = true

        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.leftAnchor.constraint(equalTo: sceneViewContainer.leftAnchor).isActive = true
        sceneView.topAnchor.constraint(equalTo: sceneViewContainer.topAnchor).isActive = true
        sceneView.rightAnchor.constraint(equalTo: sceneViewContainer.rightAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: sceneViewContainer.bottomAnchor).isActive = true

        
        //add plan view
        planView = PlanView()
        rightView.addSubview(planView)
        planView.translatesAutoresizingMaskIntoConstraints = false
        planView.leftAnchor.constraint(equalTo: rightView.leftAnchor).isActive = true
        planView.topAnchor.constraint(equalTo: rightView.topAnchor).isActive = true
        planView.rightAnchor.constraint(equalTo: rightView.rightAnchor).isActive = true
        planView.bottomAnchor.constraint(equalTo: rightView.bottomAnchor).isActive = true
        planView.reloadContent()
        listOfRightViews+=[planView]
        
        
        //add multi view
        multiView = MultiView()
        rightView.addSubview(multiView)
        multiView.translatesAutoresizingMaskIntoConstraints = false
        multiView.leftAnchor.constraint(equalTo: rightView.leftAnchor).isActive = true
        multiView.topAnchor.constraint(equalTo: rightView.topAnchor).isActive = true
        multiView.rightAnchor.constraint(equalTo: rightView.rightAnchor).isActive = true
        multiView.bottomAnchor.constraint(equalTo: rightView.bottomAnchor).isActive = true
        multiView.clipsToBounds = true
        listOfRightViews+=[multiView]
        
        
        //add cavalier view
        cavalierView = CavalierView()
        rightView.addSubview(cavalierView)
        cavalierView.translatesAutoresizingMaskIntoConstraints = false
        cavalierView.leftAnchor.constraint(equalTo: rightView.leftAnchor).isActive = true
        cavalierView.topAnchor.constraint(equalTo: rightView.topAnchor).isActive = true
        cavalierView.rightAnchor.constraint(equalTo: rightView.rightAnchor).isActive = true
        cavalierView.bottomAnchor.constraint(equalTo: rightView.bottomAnchor).isActive = true
        cavalierView.clipsToBounds = true
        listOfRightViews+=[cavalierView]
        
        
        //add isometric view
        isometricView = IsometricView()
        rightView.addSubview(isometricView)
        isometricView.translatesAutoresizingMaskIntoConstraints = false
        isometricView.leftAnchor.constraint(equalTo: rightView.leftAnchor).isActive = true
        isometricView.topAnchor.constraint(equalTo: rightView.topAnchor).isActive = true
        isometricView.rightAnchor.constraint(equalTo: rightView.rightAnchor).isActive = true
        isometricView.bottomAnchor.constraint(equalTo: rightView.bottomAnchor).isActive = true
        isometricView.clipsToBounds = true
        listOfRightViews+=[isometricView]
        
        
        //add code view
        codeView = CodeView()
        rightView.addSubview(codeView)
        codeView.translatesAutoresizingMaskIntoConstraints = false
        codeView.leftAnchor.constraint(equalTo: rightView.leftAnchor).isActive = true
        codeView.topAnchor.constraint(equalTo: rightView.topAnchor).isActive = true
        codeView.rightAnchor.constraint(equalTo: rightView.rightAnchor).isActive = true
        codeView.bottomAnchor.constraint(equalTo: rightView.bottomAnchor).isActive = true
        codeView.createContent()
        codeView.clipsToBounds = true
        listOfRightViews+=[codeView]
        
        rightView.bringSubviewToFront(planView)
        
        
        
        
    
        
        
        #if targetEnvironment(macCatalyst)
        coloredLinesSubscriber = UserDefaults.standard
                .publisher(for: \.settings_axisLine)
                .sink(receiveValue: {_ in renewSettings(settings: self.currentSettings())})
        
        numberedLinesSubscriber = UserDefaults.standard
                .publisher(for: \.settings_axisNumbers)
                .sink(receiveValue: {_ in renewSettings(settings: self.currentSettings())})
        
        typeOfCubeSubscriber = UserDefaults.standard
                .publisher(for: \.settings_typeOfCubes)
                .sink(receiveValue: {_ in renewSettings(settings: self.currentSettings())})
                
        numberOfCubesSubscriber = UserDefaults.standard
                .publisher(for: \.settings_numberOfCubes)
                .sink(receiveValue: {_ in renewSettings(settings: self.currentSettings())})
        
        loopsSubscriber = UserDefaults.standard
                .publisher(for: \.settings_loops)
                .sink(receiveValue: {_ in renewSettings(settings: self.currentSettings())})
        
        variablesSubscriber = UserDefaults.standard
                .publisher(for: \.settings_variables)
                .sink(receiveValue: {_ in renewSettings(settings: self.currentSettings())})
        #endif
        

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func currentSettings() -> Settings{
        return Settings(
            appVersion: Double(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0") ?? 0,
            axesNumbersAreEnabled: UserDefaults.standard.settings_axisNumbers,
            coloredAxesAreEnabled: UserDefaults.standard.settings_axisLine,
            typeOfCubes: UserDefaults.standard.object(forKey: "settings_typeOfCubes") as! Int,
            numberOfFields: UserDefaults.standard.object(forKey: "settings_numberOfCubes") as! Int,
            loopsAreEnabled: UserDefaults.standard.settings_loops,
            variablesAreEnabled: UserDefaults.standard.settings_variables,
            selectedLeftView: self.leftViewSegmentControl.selectedSegmentIndex,
            selectedRightView: self.rightViewSegmentControl.selectedSegmentIndex,
            visibilityOfLeftView: self.leftViewSwitch.isOn,
            visibilityOfRightView: self.rightViewSwitch.isOn,
            cameraYAngle: sceneView.cameraOrbit.eulerAngles.y,
            cameraXAngle: sceneView.cameraOrbit.eulerAngles.x,
            cameraZPposition: sceneView.cameraNode.position.z,
            visibilityOfXCurtain: sceneView.xCurtainIsVisible,
            visibilityOfYCurtain: sceneView.yCurtainIsVisible,
            cubeOpacity: sceneView.cubeOpacity,
            multiViewZoomLevel: multiView.leftContentView.transform.a,
            insertLineNumber: codeView.insertLineNumber,
            lightMode: lightMode)
    }
    
    //popover for manual
    @objc func popoverInfo(sender: UIButton){
        let popoverViewController = self.storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
        popoverViewController.modalPresentationStyle = .popover
        
        let popoverPresentationController = popoverViewController.popoverPresentationController
        popoverPresentationController?.delegate = self
        popoverPresentationController?.permittedArrowDirections = .down
        popoverPresentationController?.sourceView = sender

        if #available(iOS 13.0, *) {
            popoverPresentationController?.sourceRect.origin.x = sender.frame.width/2
        }
        else{
            popoverPresentationController?.sourceRect.origin.x = 0.55*sender.frame.width
        }
        popoverPresentationController?.sourceRect.origin.y = 0
        
        self.present(popoverViewController, animated: true, completion: nil)
    }
    
    
    //popover for preferences
    @objc func popoverPreferences(sender: UIButton){
        let popoverViewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! PreferencesViewController
        popoverViewController.modalPresentationStyle = .popover
        
        let popoverPresentationController = popoverViewController.popoverPresentationController
        popoverPresentationController?.delegate = self
        
        popoverPresentationController?.permittedArrowDirections = .down
        popoverPresentationController?.sourceView = sender
        popoverPresentationController?.sourceRect.origin.x = sender.frame.width/2
        popoverPresentationController?.sourceRect.origin.y = 0

        self.present(popoverViewController, animated: true, completion: nil)
    }
    


    //change left view
    @IBAction func tapLeftViewSegmentControl(_ sender: UISegmentedControl) {
        changeLeftView(index: sender.selectedSegmentIndex)
    }
    func changeLeftView(index: Int){
        //if plan view is chosen on left side
        if(index == 1){
            leftView.addSubview(planView)
            planView.leftAnchor.constraint(equalTo: leftView.leftAnchor).isActive = true
            planView.topAnchor.constraint(equalTo: leftView.topAnchor).isActive = true
            planView.rightAnchor.constraint(equalTo: leftView.rightAnchor).isActive = true
            planView.bottomAnchor.constraint(equalTo: leftView.bottomAnchor).isActive = true
            planView.reloadContent()

            rightViewSegmentControl.setEnabled(false, forSegmentAt: 0)
            leftView.bringSubviewToFront(planView)
            if(rightViewSegmentControl.selectedSegmentIndex == -1){
                rightView.alpha = 0
            }
        }
        //if scene view is chosen on left side
        else{
            if(UIDevice.current.userInterfaceIdiom == .pad){
                if(rightViewSwitch.isOn == true){
                    rightView.alpha = 1
                }
            }
            else{
                rightView.alpha = 1
            }
            rightViewSegmentControl.setEnabled(true, forSegmentAt: 0)
            if(rightViewSegmentControl.selectedSegmentIndex == -1){
                rightView.addSubview(planView)
                planView.leftAnchor.constraint(equalTo: rightView.leftAnchor).isActive = true
                planView.topAnchor.constraint(equalTo: rightView.topAnchor).isActive = true
                planView.rightAnchor.constraint(equalTo: rightView.rightAnchor).isActive = true
                planView.bottomAnchor.constraint(equalTo: rightView.bottomAnchor).isActive = true
                planView.reloadContent()
                rightViewSegmentControl.selectedSegmentIndex = 0
            }
            leftView.bringSubviewToFront(sceneViewContainer)
        }
    }

    //show or hide left view
    @IBAction func tapLeftViewSwitch(_ sender: UISwitch) {
        changeLeftViewVisibility(isVisible: sender.isOn)
    }
    func changeLeftViewVisibility(isVisible: Bool){
        if(isVisible == true){
            leftView.alpha = 1
        }
        else{
            leftView.alpha = 0
        }
    }
    
    func renewVisibleView(index: Int){
        switch index{
        case 1:
//            break
            multiView.updateShadows()
        case 2:
            cavalierView.updateCavalierCubes()
        case 3:
            isometricView.updateCubes()
        default:
            break
        }
    }
    
    
    
    
    //change right view
    @IBAction func tapRightViewSegmentControl(_ sender: UISegmentedControl) {
        changeRightView(index: sender.selectedSegmentIndex)
    }
    func changeRightView(index: Int){
        if(UIDevice.current.userInterfaceIdiom == .pad){
            if(rightViewSwitch.isOn == true){
                rightView.alpha = 1
            }
        }
        else{
            rightView.alpha = 1
        }
        //if plan view is chosen on right side
        if(index == 0){
            rightView.addSubview(planView)
            planView.leftAnchor.constraint(equalTo: rightView.leftAnchor).isActive = true
            planView.topAnchor.constraint(equalTo: rightView.topAnchor).isActive = true
            planView.rightAnchor.constraint(equalTo: rightView.rightAnchor).isActive = true
            planView.bottomAnchor.constraint(equalTo: rightView.bottomAnchor).isActive = true
            planView.reloadContent()
        }
        if(rightViewSegmentControl.selectedSegmentIndex == -1){
            rightView.alpha = 0
        }
        else{
            rightView.bringSubviewToFront(listOfRightViews[index])
        }
        
        //update visible views
        renewVisibleView(index: index)
        
        //show or hide multi view axis
        if(index == 1){
            sceneView.showMultiViewAxis()
        }
        else{
            sceneView.hideMultiViewAxis()
        }

        
        //show or hide isometric axis
        if(index == 3){
            sceneView.showIsometricAxis()
        }
        else{
            sceneView.hideIsometricAxis()
        }

        //disable code tracing, wenn right view is changed
        if(typeOfCubes == 0 && codeIsTracing){
            codeView.endCodeTracing()
        }
    }
    
    //show or hide right view
    @IBAction func tapRightViewSwitch(_ sender: UISwitch) {
        changeRightViewVisibility(isVisible: sender.isOn)
    }
    func changeRightViewVisibility(isVisible: Bool){
        if(isVisible == true){
            rightView.alpha = 1
        }
        else{
            rightView.alpha = 0
        }
    }
    
    //adjust right view
    func changeVisibilityOfRightSegmentControlItems(){
        //enable code view, when wooden cubes are chosen
        if(typeOfCubes == 0){
            rightViewSegmentControl.setEnabled(true, forSegmentAt: 4)
        }
        else{
            if(rightViewSegmentControl.selectedSegmentIndex == 4){
                if(leftViewSegmentControl.selectedSegmentIndex == 0){
                    rightViewSegmentControl.selectedSegmentIndex = 0
                    rightView.bringSubviewToFront(planView)
                }
                else{
                    rightViewSegmentControl.selectedSegmentIndex = 1
                    rightView.bringSubviewToFront(multiView)
                }
            }
            rightViewSegmentControl.setEnabled(false, forSegmentAt: 4)
        }
    }

    
    //delete button for all cubes
    @IBAction func pressDeleteButton(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: NSLocalizedString("DeleteHead",comment:"Delete all cubes?"), message:
            NSLocalizedString("DeleteQuestion",comment:"Do you really want to delete all cubes?"), preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("DeleteCancel",comment:"Cancel"), style: UIAlertAction.Style.cancel,handler: nil))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("DeleteDelete",comment:"Delete"), style: UIAlertAction.Style.destructive,handler: {(alert: UIAlertAction) in
            sceneView.removeAllCubes()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    //when dark or light mode is changed
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        sceneView.renewColors()
        codeView.codeTracingView.currentActionCirlce.layer.borderColor = labelColor.cgColor
    }
 
    //when screen size is changed (on Mac)
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        multiView.renewContent()
        cavalierView.renewContent()
        isometricView.renewContent()
    }
}
