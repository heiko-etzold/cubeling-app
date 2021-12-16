//
//  Global.swift
//  Cubeling
//
//  Created by Heiko Etzold on 31.05.16.
//  MIT License
//


import Foundation
import UIKit


/* GLOBAL APP SETTING */

var axesNumbersAreEnabled = Bool(true)
var coloredAxesAreEnabled = Bool(true)
var numberOfFields = Int(11)
var typeOfCubes = Int(0)
var loopsAreEnabled = Bool(true)
var variablesAreEnabled = Bool(true)


/* VIEWS AND OTHER SETTINGS */

var sceneView : SceneView!
var planView : PlanView = PlanView()
var multiView : MultiView = MultiView()
var cavalierView : CavalierView = CavalierView()
var isometricView : IsometricView = IsometricView()
var codeView : CodeView = CodeView()

var listOfRightViews : [UIView] = []

var lightMode = Int(0)




/* COLORS */

//define all colors
let xAxisColor = UIColor.systemGreen
let yAxisColor = UIColor.systemBlue

let specialElementColor = UIColor.systemRed

var lightFloorColor: UIColor{
    return UIColor(named: "lightFloorColor")!
}
var darkFloorColor: UIColor{
    return UIColor(named: "darkFloorColor")!
}
var codeLineBackround : UIColor{
    return UIColor(named: "codeLineBackground")!
}
var labelColor : UIColor{
    return UIColor(named: "labelColor")!
}
var scondaryLabelColor : UIColor{
    return UIColor(named: "scondaryLabelColor")!
}
var systemBackgroundColor : UIColor{
    return UIColor(named: "backgroundColor")!
}
var secondaryBackgroundColor : UIColor{
    return UIColor(named: "secondaryBackgroundColor")!
}

var separatorColor : UIColor{
    return UIColor(named: "separatorColor")!
}

var opaqueSeparatorColor : UIColor{
    return UIColor(named: "opaqueSeparatorColor")!
}

var shadowColor : UIColor {
    if(lightMode != 2){
        switch typeOfCubes {
        case 0:
            return UIColor(named: "woodenShadowColor")!
        case 1:
            return UIColor(named: "stackableShadowColor")!
        default:
            return UIColor(named: "magicShadowColor")!
        }
    }
    return UIColor.black
}

var sideColor : UIColor {
    if(lightMode != 2){
        switch typeOfCubes {
        case 0:
            return UIColor(named: "woodenSideColor")!
        case 1:
            return UIColor(named: "stackableSideColor")!
        default:
            return UIColor(named: "magicSideColor")!
        }
    }
    return UIColor.black
}
var topColor : UIColor {
    if(lightMode != 2){
        switch typeOfCubes {
        case 0:
            return UIColor(named: "woodenTopColor")!
        case 1:
            return UIColor(named: "stackableTopColor")!
        default:
            return UIColor(named: "magicTopColor")!
        }
    }
    return UIColor.black
}

let stringValueColor = UIColor.systemGray

//make text colorful
extension NSMutableAttributedString {
    func setColorForText(textForAttribute: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
}


/* CUBES */

var setOfCubes : Set<Cube> = []

//cube as information
struct Cube: Hashable, Codable {

    //position of cube
    var x = Int(0)
    var y = Int(0)
    var z = Int(0)
    
    //"visted" is used for deep search
    var visited = Bool(false)
    
    //hash value to compare cubes
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.x)
        hasher.combine(self.y)
        hasher.combine(self.z)
    }
}

//function to compare cubes
extension Cube: Equatable {}
func ==(firstCube: Cube, secondCube: Cube) -> Bool {
    return firstCube.x == secondCube.x && firstCube.y == secondCube.y && firstCube.z == secondCube.z
}

//for hittest to touch "through" objects
enum HitTestType: Int {
    case detectable = 0b0001
    case notDetectable = 0b0010
}



/* CODE LINE ELEMENTS */

enum CodeLineTypes: String, Codable {
    case buildCoordinates
    case buildPosition
    case removeCoordinates
    case removePosition
    case setPosition
    case changePosition
    case loopStart
    case loopEnd
}

var listOfStructCodeLines : [StructCodeLine] = []
var setOfStructCodeLines : Set<StructCodeLine> = []
var unloopedCodeLines : [CodeLine] = []

var setOfCodeLines : Set<CodeLine> = []

var characterSize = CGFloat(15)
var characterWidth = CGFloat(9.0625)

let codeLineHeight = CGFloat(35)
var codeLineWidth = CGFloat(500)
let cornerRadius = CGFloat(5)

let leftLabelOffset = CGFloat(8)

var tracingViewWidth = CGFloat(150)
var codeIsTracing = Bool(false)

struct StructCodeLineValue : Codable {
    var isSet = Bool(false)
    var value = Int(0)
}

struct StructCodeLine : Hashable, Codable{
    var identifier = Int(0)
    var values : [StructCodeLineValue] = []
    var lineType = CodeLineTypes.buildCoordinates
    var lineNumber = Int(0)
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
}

extension StructCodeLine: Equatable {}
func ==(firstStructLine: StructCodeLine, secondStructLine: StructCodeLine) -> Bool {
    return firstStructLine.identifier == secondStructLine.identifier
}

func displayPositionByLineNumber(_ lineNumber: Int, depth: Int) -> CGPoint {
    return CGPoint(x: 0, y: CGFloat(lineNumber-1)*(codeLineHeight))
}

func lineNumberByDisplayPosition(_ yPosition: CGFloat) -> Int {
    return Int(yPosition/codeLineHeight)+1
}



/* FILE ELEMENTS */

//storable settings

struct Settings : Codable {
    var appVersion : Double
    var axesNumbersAreEnabled = Bool(true)
    var coloredAxesAreEnabled = Bool(true)
    var typeOfCubes = Int(0)
    var numberOfFields = Int(0)
    var loopsAreEnabled = Bool(true)
    var variablesAreEnabled = Bool(true)
    var selectedLeftView : Int
    var selectedRightView : Int
    var visibilityOfLeftView : Bool
    var visibilityOfRightView : Bool
    var cameraYAngle : Float
    var cameraXAngle : Float
    var cameraZPposition : Float
    var visibilityOfXCurtain : Bool
    var visibilityOfYCurtain : Bool
    var cubeOpacity : Float
    var multiViewZoomLevel : CGFloat
    var insertLineNumber : Int
    var lightMode : Int?
}

struct StorableStruct : Codable {
    var settings : Settings
    var structCodeLines : [StructCodeLine]
    var cubes: Set<Cube>
}


func initDocumentPicker(urls: [URL], viewController: UIViewController?){
    guard let selectedFileURL = urls.first else{
        return
    }
    do{
        if(selectedFileURL.pathExtension == "cubeling"){
            let str = try NSString.init(contentsOf: selectedFileURL, encoding: String.Encoding.utf8.rawValue)
            openCubesByString(code: str as String)
        }
        if(selectedFileURL.pathExtension == "cubl"){
            openCubesByJSON(url: selectedFileURL)
        }
        viewController?.dismiss(animated: true, completion: nil)
    }
    catch{
    }
}

func openFileManager(delegate: UIDocumentPickerDelegate, viewController: UIViewController?){
    //open file manager
    let documentPicker = UIDocumentPickerViewController(documentTypes: ["de.heiko-etzold.Cube-Builder.cubeling","de.heiko-etzold.Cube-Builder.cubl"], in: .import)
    documentPicker.delegate = delegate
    documentPicker.allowsMultipleSelection = false
    viewController?.present(documentPicker, animated: true, completion: nil)
}

//function to open old file (prior Cubeling version 7.0)
func openCubesByString(code: String) {
        
    sceneView.removeAllCubes()

    //dismiss info or settings view controller
    if(UIDevice.current.userInterfaceIdiom == .pad){
        if let presentedViewController = (sceneView.window?.rootViewController as? ViewController)?.presentedViewController{
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    var ind = 1
    for textLine in code.split(separator: "\n").map({String($0)}){

        let list = textLine.split(separator: ":").map{String($0)}
        let type = list[0]

        switch type {
        case "st":
            let settings = Settings(
                appVersion: 0,
                axesNumbersAreEnabled: Bool(list[1])!,
                coloredAxesAreEnabled: Bool(list[2])!,
                typeOfCubes: Int(list[3])!,
                numberOfFields: Int(list[4])!,
                loopsAreEnabled: Bool(list[5])!,
                variablesAreEnabled: Bool(true),
                selectedLeftView: 0,
                selectedRightView: 0,
                visibilityOfLeftView: true,
                visibilityOfRightView: true,
                cameraYAngle: 0,
                cameraXAngle: -Float.pi * 0.15,
                cameraZPposition: 15,
                visibilityOfXCurtain: false,
                visibilityOfYCurtain: false,
                cubeOpacity: 1,
                multiViewZoomLevel: 1,
                insertLineNumber: 1,
                lightMode: 0)
            
            renewSettings(settings: settings)
            
            //show alert when old file is opend
            if let viewController = sceneView.window?.rootViewController as? ViewController{
                let alertController = UIAlertController(title: "CubeBuildingOld".localized(), message: "CubeBuildingOldText".localized(), preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
                viewController.present(alertController, animated: true, completion: nil)
            }
        
        case "bc":
            _ = codeView.addCodeLine(type: .buildCoordinates)
        case "rc":
            _ = codeView.addCodeLine(type: .removeCoordinates)
        case "bp":
            _ = codeView.addCodeLine(type: .buildPosition)
        case "rp":
            _ = codeView.addCodeLine(type: .removePosition)
        case "sp":
            _ = codeView.addCodeLine(type: .setPosition)
        case "cp":
            _ = codeView.addCodeLine(type: .changePosition)
        case "lb":
            _ = codeView.addCodeLine(type: .loopStart)
        case "le":
            codeView.insertLineNumber+=1
            
        case "cu":
            sceneView.addCube(x: Int(list[1])!, y: Int(list[2])!, z: Int(list[3])!)
        default:
            break
        }

        
        if(["bc","rc","bp","rp","sp","cp","lb","le"].contains(type)){
            if let interestedLine = setOfCodeLines.first(where: {$0.lineNumber == ind}){
                var valInt = 0
                for value in list[1..<list.count]{
                    if(value == "?"){
                        interestedLine.listOfValues[valInt].valueIsSet = false
                        interestedLine.listOfValues[valInt].value = 0
                    }
                    else{
                        interestedLine.listOfValues[valInt].valueIsSet = true
                        interestedLine.listOfValues[valInt].value = Int(value) ?? 0
                    }
                    interestedLine.renewCodeLine()

                    valInt += 1
                }
            }
            ind += 1
        }
        print("Cubes opened")
        codeView.showAllCubes()
    }
}


//function to open new file (up to Cubeling version 7.0)
func openCubesByJSON(url: URL){
    sceneView.removeAllCubes()

    //dismiss info or settings view controller
    if(UIDevice.current.userInterfaceIdiom == .pad){
        if let presentedViewController = (sceneView.window?.rootViewController as? ViewController)?.presentedViewController{
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    do {
        let decoder = JSONDecoder()

        let input = try String(contentsOf: url)
        let json = input.data(using: .utf8)

        print("\n\n\nInput")
        print(input)
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        let product = try! decoder.decode(StorableStruct.self, from: json!)
        print("\n\n\nProduct")
        print(product)

        let settings = product.settings
        
        print("Jetzt wird nue gesettet")
        renewSettings(settings: settings)
        
        if(typeOfCubes == 0){
            let listOfStructLines = product.structCodeLines
            for structLine in listOfStructLines{
        
                switch structLine.lineType {
                case .buildCoordinates:
                    _ = codeView.addCodeLine(type: .buildCoordinates)
                case .removeCoordinates:
                    _ = codeView.addCodeLine(type: .removeCoordinates)
                case .buildPosition:
                    _ = codeView.addCodeLine(type: .buildPosition)
                case .removePosition:
                    _ = codeView.addCodeLine(type: .removePosition)
                case .setPosition:
                    _ = codeView.addCodeLine(type: .setPosition)
                case .changePosition:
                    _ = codeView.addCodeLine(type: .changePosition)
                case .loopStart:
                    _ = codeView.addCodeLine(type: .loopStart)
                case .loopEnd:
                    codeView.insertLineNumber+=1
                }

                if let interestedLine = setOfCodeLines.first(where: {$0.lineNumber == structLine.lineNumber}){
                    for valInt in 0..<interestedLine.listOfValues.count{
                        interestedLine.listOfValues[valInt].valueIsSet = structLine.values[valInt].isSet
                        interestedLine.listOfValues[valInt].value = structLine.values[valInt].value

                        interestedLine.renewCodeLine()
                    }
                }
            }

            if(UIDevice.current.userInterfaceIdiom == .pad){
                codeView.insertLineNumber = settings.insertLineNumber
                UIView.animate(withDuration: 0.2, animations: {
                    codeView.insertCodeLineNumberIndicator.center.y = displayPositionByLineNumber(codeView.insertLineNumber, depth: 0).y + (codeView.insertLineNumber==0 ? 5 : 0)
                })
            }
            print("Cubes opened by JSON")
            codeView.showAllCubes()
        }
        else{
            for cube in product.cubes.filter({$0.z > 0}){
                sceneView.addCube(x: cube.x, y: cube.y, z: cube.z)
            }
        }
    }
    catch{
    }
}



//general export function
func exportContentByActivity(content: [Any], sender: Any, viewController: UIViewController){
    var activityViewController: UIActivityViewController!
    activityViewController = UIActivityViewController(activityItems: content, applicationActivities: nil)
    
    if let sourceView = sender as? UIView{ //.value(forKey: "view") as! UIView
//    if(sourceView is UIView){
//        activityViewController.popoverPresentationController?.sourceView = sourceView
        activityViewController.popoverPresentationController?.sourceView = sourceView
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: sourceView.frame.width, height: sourceView.frame.height)
    }
    if let sourceBarButton = sender as? UIBarButtonItem{
        activityViewController.popoverPresentationController?.barButtonItem = sourceBarButton
    }
    viewController.present(activityViewController, animated: true, completion: nil)
}

func exportContentOnMac(url: URL, viewController: UIViewController){
    if #available(iOS 14, *) {
        let controller = UIDocumentPickerViewController(forExporting: [url])
        viewController.present(controller, animated: true)
    } else {
        let controller = UIDocumentPickerViewController(url: url, in: .exportToService)
        viewController.present(controller, animated: true)
    }
}


func prepareSafingCubeBuilding(viewController: ViewController) -> URL{
    //reduce settings if device is iPhone
    var settings = Settings(
        appVersion: Double(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0") ?? 0,
        axesNumbersAreEnabled: axesNumbersAreEnabled,
        coloredAxesAreEnabled: coloredAxesAreEnabled,
        typeOfCubes: UserDefaults.standard.object(forKey: "settings_typeOfCubes") as! Int,
        numberOfFields: UserDefaults.standard.object(forKey: "settings_numberOfCubes") as! Int,
        loopsAreEnabled: loopsAreEnabled,
        variablesAreEnabled: variablesAreEnabled,
        selectedLeftView: viewController.leftViewSegmentControl.selectedSegmentIndex,
        selectedRightView: viewController.rightViewSegmentControl.selectedSegmentIndex,
        visibilityOfLeftView: true,
        visibilityOfRightView: true,
        cameraYAngle: sceneView.cameraOrbit.eulerAngles.y,
        cameraXAngle: sceneView.cameraOrbit.eulerAngles.x,
        cameraZPposition: sceneView.cameraNode.position.z,
        visibilityOfXCurtain: false,
        visibilityOfYCurtain: false,
        cubeOpacity: 1,
        multiViewZoomLevel: multiView.leftContentView.transform.a,
        insertLineNumber: codeView.insertLineNumber,
        lightMode: 0)
    
    if(UIDevice.current.userInterfaceIdiom == .pad){
        settings = Settings(
            appVersion: Double(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0") ?? 0,
            axesNumbersAreEnabled: axesNumbersAreEnabled,
            coloredAxesAreEnabled: coloredAxesAreEnabled,
            typeOfCubes: UserDefaults.standard.object(forKey: "settings_typeOfCubes") as! Int,
            numberOfFields: UserDefaults.standard.object(forKey: "settings_numberOfCubes") as! Int,
            loopsAreEnabled: loopsAreEnabled,
            variablesAreEnabled: variablesAreEnabled,
            selectedLeftView: viewController.leftViewSegmentControl.selectedSegmentIndex,
            selectedRightView: viewController.rightViewSegmentControl.selectedSegmentIndex,
            visibilityOfLeftView: viewController.leftViewSwitch.isOn,
            visibilityOfRightView: viewController.rightViewSwitch.isOn,
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
    
    
    

    
    //create struct code lines
    listOfStructCodeLines = []
    if(typeOfCubes == 0){
        for line in setOfCodeLines.sorted(by: {$0.lineNumber < $1.lineNumber}){
            var lineType = CodeLineTypes.buildCoordinates
            switch line {
            case is CodeLineRemoveCoordinates:
                lineType = .removeCoordinates
            case is CodeLineBuildPosition:
                lineType = .buildPosition
            case is CodeLineRemovePosition:
                lineType = .removePosition
            case is CodeLineSetPosition:
                lineType = .setPosition
            case is CodeLineChangePosition:
                lineType = .changePosition
            case is CodeLineLoopStart:
                lineType = .loopStart
            case is CodeLineLoopEnd:
                lineType = .loopEnd
            default:
                lineType = .buildCoordinates
            }
            var listOfStructValues : [StructCodeLineValue] = []
            for value in line.listOfValues{
                let val = StructCodeLineValue(isSet: value.valueIsSet, value: value.value)
                listOfStructValues.append(val)
            }
            
            let structLine = StructCodeLine(identifier: 0, values: listOfStructValues, lineType: lineType, lineNumber: line.lineNumber)
            listOfStructCodeLines.append(structLine)
        }
    }
    
    //create content to safe
    let safeContent = StorableStruct(
        settings: settings,
        structCodeLines: listOfStructCodeLines,
        cubes: setOfCubes)
    
    //encode and safe content
    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("/\("CubeBuildingName".localized()).cubl")
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    do {
        let data = try encoder.encode(safeContent)
        try data.write(to: url)
    }
    catch {
    }
    
    return url
    
}






func renewSettings(settings: Settings){
    UserDefaults.standard.set(settings.axesNumbersAreEnabled, forKey: "settings_axisNumbers")
    UserDefaults.standard.set(settings.coloredAxesAreEnabled, forKey: "settings_axisLine")
    UserDefaults.standard.set(settings.typeOfCubes, forKey: "settings_typeOfCubes")
    UserDefaults.standard.set(settings.numberOfFields, forKey: "settings_numberOfCubes")
    UserDefaults.standard.set(settings.loopsAreEnabled, forKey: "settings_loops")
    UserDefaults.standard.set(settings.variablesAreEnabled, forKey: "settings_variables")

    axesNumbersAreEnabled = UserDefaults.standard.object(forKey: "settings_axisNumbers") as! Bool
    coloredAxesAreEnabled = UserDefaults.standard.object(forKey: "settings_axisLine") as! Bool
    
    let chosenTypeOfCubes = UserDefaults.standard.object(forKey: "settings_typeOfCubes") as! Int
    let chosenNumberOfFields = UserDefaults.standard.object(forKey: "settings_numberOfCubes") as! Int
    
    loopsAreEnabled = UserDefaults.standard.object(forKey: "settings_loops") as! Bool
    variablesAreEnabled = UserDefaults.standard.object(forKey: "settings_variables") as! Bool

    sceneView.reloadContent(newNumberOfFields: chosenNumberOfFields, newTypesOfCubes: chosenTypeOfCubes)
    planView.reloadContent()
    multiView.createContent()
    cavalierView.createContent()
    isometricView.createContent()
    codeView.renewEnabilityOfCodeButtons()
    
    if let viewController = sceneView.window?.rootViewController as? ViewController{
        viewController.changeLeftView(index: settings.selectedLeftView)
        viewController.leftViewSegmentControl.selectedSegmentIndex = settings.selectedLeftView
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            viewController.changeLeftViewVisibility(isVisible: settings.visibilityOfLeftView)
            viewController.leftViewSwitch.setOn(settings.visibilityOfLeftView, animated: true)
            viewController.changeRightViewVisibility(isVisible: settings.visibilityOfRightView)
            viewController.rightViewSwitch.setOn(settings.visibilityOfRightView, animated: true)
            viewController.changeVisibilityOfRightSegmentControlItems()
            
            if let settingsViewController = viewController.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as? PreferencesViewController{
                settingsViewController.changeXCurtain(isVisible: settings.visibilityOfXCurtain)
                settingsViewController.changeYCurtain(isVisible: settings.visibilityOfYCurtain)
                settingsViewController.changeCubeVisibility(opacity: settings.cubeOpacity)
            }
            if(settings.selectedRightView == 4 && settings.typeOfCubes != 0){
                viewController.changeRightView(index: 1)
                viewController.rightViewSegmentControl.selectedSegmentIndex = 1
            }
        }
        if(UIDevice.current.userInterfaceIdiom == .phone && settings.selectedRightView == 4){
            viewController.changeRightView(index: 1)
            viewController.rightViewSegmentControl.selectedSegmentIndex = 1
        }
        else{
            viewController.rightViewSegmentControl.selectedSegmentIndex = settings.selectedRightView
            viewController.changeRightView(index: settings.selectedRightView)
            if(settings.selectedRightView == 4 && settings.typeOfCubes != 0){
                viewController.changeRightView(index: 1)
                viewController.rightViewSegmentControl.selectedSegmentIndex = 1
            }
        }
    }
    sceneView.cameraOrbit.eulerAngles.y = settings.cameraYAngle
    sceneView.cameraOrbit.eulerAngles.x = settings.cameraXAngle
    sceneView.cameraNode.position.z = settings.cameraZPposition
    multiView.leftContentView.transform.a = settings.multiViewZoomLevel
    multiView.changeBackground()
    
    if let lightIsSetted = settings.lightMode{
        lightMode = lightIsSetted
    }
    else{
        lightMode = 0
    }
}


extension UserDefaults {
    @objc dynamic var settings_typeOfCubes: Int {
        return integer(forKey: "settings_typeOfCubes")
    }
    
    @objc dynamic var settings_numberOfCubes: Int {
        return integer(forKey: "settings_numberOfCubes")
    }
    
    @objc dynamic var settings_axisNumbers: Bool {
        return bool(forKey: "settings_axisNumbers")
    }

    @objc dynamic var settings_axisLine: Bool {
        return bool(forKey: "settings_axisLine")
    }

    @objc dynamic var settings_loops: Bool {
        return bool(forKey: "settings_loops")
    }

    @objc dynamic var settings_variables: Bool {
        return bool(forKey: "settings_variables")
    }

    
}




/* SOME OTHER FUNCTIONS */

//get global parent view controller of view
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

//set anchor point without moving view
extension UIView {
    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y);

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = point
    }
}


//make string localizable
extension String {
    func localized(withComment comment: String? = nil) -> String {
        
        let value = NSLocalizedString(self, comment: "")
        if value != self || NSLocale.preferredLanguages.first == "en" {
            return value
        }
        
        //fall back to en
        guard
            let path = Bundle.main.path(forResource: "Base", ofType: "lproj"),
            let bundle = Bundle(path: path)
        else { return value }
        return NSLocalizedString(self, bundle: bundle, comment: comment ?? "")
    }
}
