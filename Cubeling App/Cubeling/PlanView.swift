//
//  PlanView.swift
//  Cubeling
//
//  Created by Heiko Etzold on 06.08.15.
//  MIT License
//


import UIKit
import SceneKit

class PlanView: UIView, UIPointerInteractionDelegate {

    var listOfFloors : [PlanFloor] = []

    let codeTracingOverlay = UIView()
    let informationLabel = UILabel()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)

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

        let overlayLabel = UILabel()
        overlayLabel.text = "CodeRunningActive".localized()
        overlayLabel.font = UIFont.boldSystemFont(ofSize: overlayLabel.font.pointSize)
        overlayLabel.numberOfLines = -1
        overlayLabel.sizeToFit()
        codeTracingOverlay.addSubview(overlayLabel)
        overlayLabel.translatesAutoresizingMaskIntoConstraints = false
        overlayLabel.leftAnchor.constraint(equalTo: codeTracingOverlay.leftAnchor, constant: 100).isActive = true
        overlayLabel.rightAnchor.constraint(equalTo: codeTracingOverlay.rightAnchor, constant: -20).isActive = true
        overlayLabel.bottomAnchor.constraint(equalTo: codeTracingOverlay.bottomAnchor, constant: -15).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func reloadContent(){
       
        self.layoutIfNeeded()
        self.backgroundColor = systemBackgroundColor
        
        //remove all subviews
        for subview in self.subviews.filter({$0 != codeTracingOverlay}){
            subview.removeFromSuperview()
        }
        
        
        //add a layout view to adjust the size of content
        let layoutView = UIView()
        self.addSubview(layoutView)
        layoutView.translatesAutoresizingMaskIntoConstraints = false
        layoutView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        layoutView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        layoutView.heightAnchor.constraint(equalTo: layoutView.widthAnchor).isActive = true
        layoutView.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, multiplier: CGFloat(numberOfFields+1)/CGFloat(numberOfFields+2)).isActive = true
        layoutView.heightAnchor.constraint(lessThanOrEqualTo: self.heightAnchor, multiplier: CGFloat(numberOfFields+1)/CGFloat(numberOfFields+2)).isActive = true
        let widthContraint = layoutView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: CGFloat(numberOfFields+1)/CGFloat(numberOfFields+2))
        widthContraint.priority = UILayoutPriority(750)
        widthContraint.isActive = true
        let heightContraint = layoutView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: CGFloat(numberOfFields+1)/CGFloat(numberOfFields+2))
        heightContraint.priority = UILayoutPriority(750)
        heightContraint.isActive = true
        
        layoutView.layoutIfNeeded()
        
        
        //information, when cube is outside the grid
        self.addSubview(informationLabel)
        informationLabel.translatesAutoresizingMaskIntoConstraints = false
        informationLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        informationLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        informationLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        informationLabel.numberOfLines = -1
        informationLabel.text = "HintNumberLabelText".localized()
        
        
        //add floors
        layoutView.layoutIfNeeded()
        listOfFloors = []
        
        for y in (1 ... numberOfFields).reversed(){
            for x in (1 ... numberOfFields).reversed(){
                
                let floor = PlanFloor(x: x, y: y)

                if #available(iOS 13.4, *) {
                    floor.addInteraction(UIPointerInteraction(delegate: self))
                }
                layoutView.addSubview(floor)

                floor.translatesAutoresizingMaskIntoConstraints = false
                if(coloredAxesAreEnabled || axesNumbersAreEnabled){
                    floor.widthAnchor.constraint(equalTo: layoutView.widthAnchor, multiplier: CGFloat(1)/CGFloat(numberOfFields+1)).isActive = true
                }
                else{
                    floor.widthAnchor.constraint(equalTo: layoutView.widthAnchor, multiplier: CGFloat(1)/CGFloat(numberOfFields)).isActive = true
                }
                floor.heightAnchor.constraint(equalTo: floor.widthAnchor).isActive = true
                switch (x,y) {
                case (numberOfFields,numberOfFields):
                    floor.rightAnchor.constraint(equalTo: layoutView.rightAnchor).isActive = true
                    floor.topAnchor.constraint(equalTo: layoutView.topAnchor).isActive = true
                case (numberOfFields,_):
                    floor.rightAnchor.constraint(equalTo: layoutView.rightAnchor).isActive = true
                    floor.topAnchor.constraint(equalTo: listOfFloors.last!.bottomAnchor).isActive = true
                default:
                    floor.rightAnchor.constraint(equalTo: listOfFloors.last!.leftAnchor).isActive = true
                    floor.topAnchor.constraint(equalTo: listOfFloors.last!.topAnchor).isActive = true
                }
                listOfFloors.append(floor)
            }
        }

        
        //create colored axes
        if(coloredAxesAreEnabled){
            
            let xColoredAxes = UIView()
            xColoredAxes.backgroundColor = xAxisColor
            layoutView.addSubview(xColoredAxes)
            
            xColoredAxes.translatesAutoresizingMaskIntoConstraints = false
            xColoredAxes.rightAnchor.constraint(equalTo: layoutView.rightAnchor).isActive = true
            xColoredAxes.bottomAnchor.constraint(equalTo: layoutView.bottomAnchor).isActive = true
            xColoredAxes.widthAnchor.constraint(equalTo: layoutView.widthAnchor, multiplier: CGFloat(numberOfFields)/CGFloat(numberOfFields+1)).isActive = true
            xColoredAxes.heightAnchor.constraint(equalTo: layoutView.heightAnchor, multiplier: 0.9/CGFloat(numberOfFields+1)).isActive = true
            
            let yColoredAxes = UIView()
            yColoredAxes.backgroundColor = yAxisColor
            layoutView.addSubview(yColoredAxes)
            
            yColoredAxes.translatesAutoresizingMaskIntoConstraints = false
            yColoredAxes.leftAnchor.constraint(equalTo: layoutView.leftAnchor).isActive = true
            yColoredAxes.topAnchor.constraint(equalTo: layoutView.topAnchor).isActive = true
            yColoredAxes.widthAnchor.constraint(equalTo: layoutView.widthAnchor, multiplier: 0.9/CGFloat(numberOfFields+1)).isActive = true
            yColoredAxes.heightAnchor.constraint(equalTo: layoutView.heightAnchor, multiplier: CGFloat(numberOfFields)/CGFloat(numberOfFields+1)).isActive = true
        }

        
        //create axes numbers
        if(axesNumbersAreEnabled == true){
            for x in 1 ... numberOfFields{
                let xNumber = UILabel()
                xNumber.text = "\(x)"
                xNumber.textAlignment = .center
                xNumber.textColor = coloredAxesAreEnabled ? systemBackgroundColor : xAxisColor
                layoutView.addSubview(xNumber)
                xNumber.translatesAutoresizingMaskIntoConstraints = false
                if let connectedFloor = listOfFloors.first(where: {$0.x == x && $0.y == 1}){
                    xNumber.widthAnchor.constraint(equalTo: connectedFloor.widthAnchor).isActive = true
                    xNumber.heightAnchor.constraint(equalTo: xNumber.widthAnchor, multiplier: 0.9).isActive = true
                    xNumber.bottomAnchor.constraint(equalTo: layoutView.bottomAnchor).isActive = true
                    xNumber.centerXAnchor.constraint(equalTo: connectedFloor.centerXAnchor).isActive = true
                }
                xNumber.layoutIfNeeded()
                xNumber.font = UIFont(name: "Menlo", size: xNumber.frame.width/3)
            }
            for y in 1 ... numberOfFields{
                let yNumber = UILabel()
                yNumber.text = "\(y)"
                yNumber.textAlignment = .center
                yNumber.textColor = coloredAxesAreEnabled ? systemBackgroundColor : yAxisColor
                layoutView.addSubview(yNumber)
                yNumber.translatesAutoresizingMaskIntoConstraints = false
                if let connectedFloor = listOfFloors.first(where: {$0.y == y && $0.x == 1}){
                    yNumber.heightAnchor.constraint(equalTo: connectedFloor.heightAnchor).isActive = true
                    yNumber.widthAnchor.constraint(equalTo: yNumber.heightAnchor, multiplier: 0.9).isActive = true
                    yNumber.leftAnchor.constraint(equalTo: layoutView.leftAnchor).isActive = true
                    yNumber.centerYAnchor.constraint(equalTo: connectedFloor.centerYAnchor).isActive = true
                }
                yNumber.layoutIfNeeded()
                yNumber.font = UIFont(name: "Menlo", size: yNumber.frame.height/3)
            }
        }
        
        
        //bring overlay to front
        bringSubviewToFront(codeTracingOverlay)

        //update all field numbers
        updateFieldNumbers()
    }
    
    
    //highlight field, when mouse pointer is over it
    @available(iOS 13.4, *)
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        var pointerStyle: UIPointerStyle? = nil
        if let interactionView = interaction.view {
            let targetedPreview = UITargetedPreview(view: interactionView)
            self.bringSubviewToFront(interactionView)
            if(typeOfCubes==0 && codeIsTracing == false){
                pointerStyle = UIPointerStyle(effect: UIPointerEffect.hover(targetedPreview, preferredTintMode: .overlay, prefersShadow: true, prefersScaledContent: true))
            }
        }
        return pointerStyle
    }
    
    
    //update field numbers
    func updateFieldNumbers(){
        informationLabel.alpha = 0
        for cube in setOfCubes{
            if((cube.x <= 0 || cube.x>numberOfFields || cube.y <= 0 || cube.y>numberOfFields) && cube.z != 0){
                informationLabel.alpha = 1
            }
        }
        for floor in listOfFloors{
            floor.updateFieldNumber()
        }
    }
}
