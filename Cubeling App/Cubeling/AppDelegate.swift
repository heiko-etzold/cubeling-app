//
//  AppDelegate.swift
//  Cubeling
//
//  Created by Heiko Etzold on 06.08.15.
//  MIT License
//


import UIKit
import Foundation




extension AppDelegate : UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        initDocumentPicker(urls: urls, viewController: window?.rootViewController)

    }
}



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

//    #if targetEnvironment(macCatalyst)
    @available(iOS 13.0, *)
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        /* Do something */
        
        builder.remove(menu: .services)
        builder.remove(menu: .edit)
        builder.remove(menu: .format)
        builder.remove(menu: .toolbar)
        if #available(iOS 14.0, *) {
            builder.remove(menu: .openRecent)
        } else {
        }
        
        let safeCommand =  UIKeyCommand(input: "S", modifierFlags: [.command], action: #selector(safeCubeBuilding))
        safeCommand.title = NSLocalizedString("ExportCubeText", comment: "Export Cube Building")

        let openCommand = UIKeyCommand(input: "O", modifierFlags: [.command], action: #selector(openCubeBuilding))
        openCommand.title = NSLocalizedString("ImportCubeText", comment: "Import Cube Building")


        
        let upperMenu = UIMenu(title: "", image: nil, options: .displayInline, children: [safeCommand])
        
        let downerMenu = UIMenu(title: "", image: nil, options: .displayInline, children: [openCommand])


        builder.insertChild(upperMenu, atStartOfMenu: .file)
        builder.insertSibling(downerMenu, beforeMenu: .close)
    }
    

    
    @objc func safeCubeBuilding(){
        if let viewController = window?.rootViewController as? ViewController{
            #if targetEnvironment(macCatalyst)
            let url = prepareSafingCubeBuilding(viewController: viewController)
            exportContentOnMac(url: url, viewController: viewController)
            #else
            exportContentByActivity(content: [prepareSafingCubeBuilding(viewController: viewController)], sender: viewController.organizeButton as Any, viewController: viewController)
            #endif
        }
    }
    
    //open cube building
    @objc func openCubeBuilding() {
        openFileManager(delegate: self, viewController: window?.rootViewController)
    }
    
    
    //when app was completely startet
    func applicationDidFinishLaunching(_ application: UIApplication) {
        
        //disable title bar on Mac
        #if targetEnvironment(macCatalyst)
        guard let windowScene = window?.windowScene else { return }

        if let titlebar = windowScene.titlebar {
            titlebar.titleVisibility = .hidden
            titlebar.toolbar = nil
        }
        #endif
        
        
        //default values, if setting didn't set before
        var appDefaults = Dictionary<String, AnyObject>()
        appDefaults["settings_axisNumbers"] = true as AnyObject?
        appDefaults["settings_axisLine"] = true as AnyObject?
        appDefaults["settings_numberOfCubes"] = 7 as AnyObject?
        appDefaults["settings_typeOfCubes"] = 0  as AnyObject?
        appDefaults["settings_loops"] = true as AnyObject?
        appDefaults["settings_variables"] = true as AnyObject?

        UserDefaults.standard.register(defaults: appDefaults)
        UserDefaults.standard.synchronize()
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    //when app was closed
    func applicationDidEnterBackground(_ application: UIApplication) {
        if(typeOfCubes == 0){
            codeView.endCodeTracing()
        }
    }

    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    

    //when app becomes active (i.e. open, reopen, comming back from settings, ...)
    func applicationDidBecomeActive(_ application: UIApplication) {

        //set values by settings
        axesNumbersAreEnabled = UserDefaults.standard.object(forKey: "settings_axisNumbers") as! Bool
        coloredAxesAreEnabled = UserDefaults.standard.object(forKey: "settings_axisLine") as! Bool
        let chosenNumberOfFields = UserDefaults.standard.object(forKey: "settings_numberOfCubes") as! Int
        let chosenTypeOfCubes = UserDefaults.standard.object(forKey: "settings_typeOfCubes") as! Int
        loopsAreEnabled = UserDefaults.standard.object(forKey: "settings_loops") as! Bool
        variablesAreEnabled = UserDefaults.standard.object(forKey: "settings_variables") as! Bool

        //renew all views
        sceneView.reloadContent(newNumberOfFields: chosenNumberOfFields, newTypesOfCubes: chosenTypeOfCubes)
        planView.reloadContent()
        multiView.createContent()
        cavalierView.createContent()
        isometricView.createContent()
        if(!codeIsTracing){
            codeView.renewEnabilityOfCodeButtons()
        }
        codeView.endCodeTracing()

        if(UIDevice.current.userInterfaceIdiom == .pad){
            if let viewController = self.window?.rootViewController as? ViewController{
                viewController.changeVisibilityOfRightSegmentControlItems()
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
     
    
    
    //open cube file
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let security = url.startAccessingSecurityScopedResource()
        
        //if file doesn't exist, download file and show alert that file doesn't exist
        if(!FileManager.default.fileExists(atPath: url.path)){
            do{
                try FileManager.default.startDownloadingUbiquitousItem(at: url)
            }
            catch{
            }
            let alertController = UIAlertController(
                title: "CubeBuildingNotLoaded".localized(),
                message: "CubeBuildingNotLoadedText".localized(),
                preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "DeleteCancel".localized(), style: UIAlertAction.Style.cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "TryAgain".localized(), style: UIAlertAction.Style.default, handler: {(alert: UIAlertAction) in
                _ = self.application(app, open: url, options: options)
            }))
            (self.window?.rootViewController as! ViewController).present(alertController, animated: true, completion: nil)
        }
        
        //otherwise open file
        else{
            do{
                //old file (prior Cubeling version 7.0)
                if(url.pathExtension == "cubeling"){
                    let str = try NSString.init(contentsOf: url, encoding: String.Encoding.utf8.rawValue)
                    openCubesByString(code: str as String)
                }
                //new file (up to Cubeling version 7.0)
                if(url.pathExtension == "cubl"){
                    openCubesByJSON(url: url)
                }
            }
            catch{
            }
            if(security){
                url.stopAccessingSecurityScopedResource()
            }
        }
        return true
    }
}
