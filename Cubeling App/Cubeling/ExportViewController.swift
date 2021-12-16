//
//  ExportViewController.swift
//  Cubeling
//
//  Created by Heiko Etzold on 21.11.19.
//  MIT License
//


import UIKit
import MobileCoreServices
import Darwin


//extension to open old or new file via document picker
extension ExportViewController : UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        initDocumentPicker(urls: urls, viewController: self)
    }
}


class ExportViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var exportViewsButton: UIButton!
    @IBOutlet weak var exportCodeButtonOutlet: UIButton!
    @IBOutlet weak var exportCodeImageButtonOutlet: UIButton!

    @IBOutlet weak var exportSceneSelectButton: UIButton!
    @IBOutlet weak var exportPlanSelectButton: UIButton!
    @IBOutlet weak var exportMultiSelectButton: UIButton!
    @IBOutlet weak var exportCavalierSelectButton: UIButton!
    @IBOutlet weak var exportIsometricSelectButton: UIButton!
    @IBOutlet weak var exportCodeSelectButton: UIButton!
    
    @IBOutlet weak var dismissButtonOutlet: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.preferredContentSize = self.view.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize
        )

        //set navigation bar, depending on iOS version
        exportViewsButton.titleLabel?.numberOfLines = 0
        dismissButtonOutlet.setTitle("DeleteCancel".localized(), for: .normal)
        navigationBar.topItem?.title = "CubeExport".localized()
        if #available(iOS 13.0, *) {
            #if targetEnvironment(macCatalyst)
            #else
            if(UIDevice.current.userInterfaceIdiom == .pad){
                dismissButtonOutlet.isHidden = true
            }
            #endif
        }
        else{
        }


        //set buttons on/off, depending on visible views
        if let vc = UIApplication.shared.windows.first?.rootViewController as? ViewController{

            var leftIsVisble = true
            var rightIsVisible = true
            if(UIDevice.current.userInterfaceIdiom == .pad){
                leftIsVisble = vc.leftViewSwitch.isOn
                rightIsVisible = vc.rightViewSwitch.isOn
            }

            changeSelection(button: exportSceneSelectButton, selection: vc.leftViewSegmentControl.selectedSegmentIndex == 0 && leftIsVisble)

            changeSelection(button: exportPlanSelectButton, selection: (vc.leftViewSegmentControl.selectedSegmentIndex == 1 && leftIsVisble) || (vc.rightViewSegmentControl.selectedSegmentIndex == 0 && rightIsVisible))

            changeSelection(button: exportMultiSelectButton, selection: vc.rightViewSegmentControl.selectedSegmentIndex == 1 && rightIsVisible)
            
            changeSelection(button: exportCavalierSelectButton, selection: vc.rightViewSegmentControl.selectedSegmentIndex == 2 && rightIsVisible)
            
            changeSelection(button: exportIsometricSelectButton, selection: vc.rightViewSegmentControl.selectedSegmentIndex == 3 && rightIsVisible)
            
            changeSelection(button: exportCodeSelectButton, selection: vc.rightViewSegmentControl.selectedSegmentIndex == 4 && rightIsVisible)

        }

        //disable code export when non wooden cube is chosen
        if(typeOfCubes != 0 && UIDevice.current.userInterfaceIdiom == .pad){
            exportCodeButtonOutlet.isEnabled = false
            exportCodeImageButtonOutlet.isEnabled = false
            exportCodeSelectButton.isEnabled = false
        }
    }
    
    
    //to dismiss when canceled
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func dismissButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    

    //when select button is pressed, change selection
    @IBAction func pressExportSelectButton(_ sender: UIButton) {
        changeSelection(button: sender, selection: !sender.isSelected)
    }
    func changeSelection(button: UIButton, selection: Bool){
        button.layer.cornerRadius = 5
        var originTintColor = scondaryLabelColor
        if(button.isSelected){
            originTintColor = button.backgroundColor!
        }
        else{
            originTintColor = button.tintColor
        }
        
        button.isSelected = selection
        if(button.isSelected){
            button.tintColor = systemBackgroundColor
            button.backgroundColor = originTintColor
        }
        else{
            button.tintColor = originTintColor
            button.backgroundColor =  .clear
        }
    }
    
    
    //export images
    @IBAction func exportImages(_ sender: UIButton) {
        
        //create images
        var items : [Any] = []

        UIGraphicsBeginImageContext(sceneView.frame.size);
        sceneView.drawHierarchy(in: sceneView.bounds, afterScreenUpdates: true)
        let sceneShot = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        if(exportSceneSelectButton.isSelected){
            items += [sceneShot]
        }

        UIGraphicsBeginImageContext(planView.frame.size);
        planView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let planShot = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        if(exportPlanSelectButton.isSelected){
            items += [planShot]
        }
        
        UIGraphicsBeginImageContext(multiView.frame.size);
        multiView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let multiShot = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        if(exportMultiSelectButton.isSelected){
            items += [multiShot]
        }
        
        UIGraphicsBeginImageContext(cavalierView.frame.size);
        cavalierView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let cavalierShot = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        if(exportCavalierSelectButton.isSelected){
            items += [cavalierShot]
        }
        
        UIGraphicsBeginImageContext(isometricView.frame.size);
        isometricView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let isoShot = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        if(exportIsometricSelectButton.isSelected){
            items += [isoShot]
        }
        
        UIGraphicsBeginImageContext(codeView.frame.size);
        codeView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let codeShot = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        if(exportCodeSelectButton.isSelected){
            items += [codeShot]
        }
        
        //show export activity
        exportContentByActivity(content: items, sender: sender, viewController: self)
    }
    
    
    //export code text
    @IBAction func exportCodeText(_ sender: UIButton) {
        var codeText = ""
        for line in setOfCodeLines.sorted(by: {$0.lineNumber < $1.lineNumber}){
            codeText += "\(line.label.text ?? "")\n"
        }
        exportContentByActivity(content: [codeText], sender: sender, viewController: self)
    }
    
    
    
    //export cube building
    @IBAction func saveCubeBuilding(_ sender: UIButton) {
        #if targetEnvironment(macCatalyst)
        if let viewController = self.presentingViewController as? ViewController{
            let url = prepareSafingCubeBuilding(viewController: viewController)
            exportContentOnMac(url: url, viewController: self)
        }
        #else
        if let viewController = view.window?.rootViewController as? ViewController{
            
            exportContentByActivity(content: [prepareSafingCubeBuilding(viewController: viewController)], sender: sender, viewController: self)
        }
        #endif
    }
    
    
    //open cube building
    @IBAction func openCubeBuilding(_ sender: UIButton) {
        openFileManager(delegate: self, viewController: self)
    }


}

