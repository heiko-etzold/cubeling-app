//
//  MultiView.swift
//  Cubeling
//
//  Created by Heiko Etzold on 08.08.15.
//  MIT License
//


import UIKit

class MultiView: UIView {
    
    var leftContentView = UIView()
    var rightContentView = UIView()
    var topView = UIView()
    var sideView = UIView()

    let informationLabel = UILabel()
    
    var listOfFloors : [PlanFloor] = []
    var setOfFrontShadows : Set<PlanFloor> = []
    var setOfSideShadows : Set<PlanFloor> = []
    var listOfFrontShadows : [PlanFloor] = []
    var listOfSideShadows : [PlanFloor] = []

    var listOfSeperatorLines : [UIView] = []

    var multiViewScaleFactor = CGFloat(1)
    
    var fieldWidth = CGFloat(1)
    var offset = CGFloat(0)
    
    override init(frame: CGRect) {

        super.init(frame: frame)
        self.backgroundColor = systemBackgroundColor

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomBackground))
        self.addGestureRecognizer(pinchGesture)
        
        createContent()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func createContent(){
    
        //empty all lists and sets
        listOfSeperatorLines = []
        listOfFloors = []
        listOfFrontShadows = []
        setOfFrontShadows = []
        setOfSideShadows = []
        listOfSideShadows = []

        //set scale factor
        multiViewScaleFactor = (coloredAxesAreEnabled || axesNumbersAreEnabled) ? (CGFloat(numberOfFields)+1.5)/CGFloat(numberOfFields+1) : (CGFloat(numberOfFields)+0.5)/CGFloat(numberOfFields)
        
        //remove all subview
        for view in self.subviews{
            view.removeFromSuperview()
        }
        
        //information, when cube is outside the grid
        self.addSubview(informationLabel)
        informationLabel.translatesAutoresizingMaskIntoConstraints = false
        informationLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        informationLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        informationLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        informationLabel.numberOfLines = -1
        informationLabel.text = "HintShadowLabelText".localized()
        
        
        //left part of multiview
        leftContentView = UIView()
        leftContentView.backgroundColor = .clear
        leftContentView.layer.anchorPoint = CGPoint(x: 0, y: 1)
        self.addSubview(leftContentView)
        leftContentView.translatesAutoresizingMaskIntoConstraints = false
        leftContentView.centerXAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        leftContentView.centerYAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        leftContentView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        leftContentView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true

        
        //view from above
        topView = UIView()
        topView.backgroundColor = .clear
        leftContentView.addSubview(topView)
        topView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        topView.frame.size.width = 1000
        topView.frame.size.height = topView.frame.width*multiViewScaleFactor


        //right part of multiview
        rightContentView = UIView()
        rightContentView.backgroundColor = .clear
        rightContentView.layer.anchorPoint = CGPoint(x: -1, y: 1)
        self.addSubview(rightContentView)
        rightContentView.translatesAutoresizingMaskIntoConstraints = false
        rightContentView.leftAnchor.constraint(equalTo: leftContentView.leftAnchor).isActive = true
        rightContentView.widthAnchor.constraint(equalTo: leftContentView.widthAnchor).isActive = true
        rightContentView.centerYAnchor.constraint(equalTo: leftContentView.centerYAnchor).isActive = true
        rightContentView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
             
        
        //view from left
        sideView = UIView()
        sideView.backgroundColor = .clear
        rightContentView.addSubview(sideView)
        sideView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        sideView.frame.size.width = 1000*multiViewScaleFactor
        sideView.frame.size.height = 1000*multiViewScaleFactor
        sideView.frame.origin = topView.frame.origin
        
        renewContent()

        //multi view axis on left side
        let leftAxis = UIView(frame: CGRect(x: 0, y: -0.05*fieldWidth, width: CGFloat(numberOfFields)*fieldWidth, height: 0.1*fieldWidth))
        if(coloredAxesAreEnabled || axesNumbersAreEnabled){
            leftAxis.frame.origin.x = fieldWidth
        }
        leftAxis.backgroundColor = specialElementColor
        topView.addSubview(leftAxis)

        let leftAxisSquare = UIView(frame: CGRect(x: -leftAxis.frame.height, y: -leftAxis.frame.height/2, width: 2*leftAxis.frame.height, height: 2*leftAxis.frame.height))
        leftAxisSquare.backgroundColor = specialElementColor
        leftAxis.addSubview(leftAxisSquare)
        
        let leftAxisCircle = UIView(frame: CGRect(x: leftAxis.frame.width-leftAxis.frame.height, y: -leftAxis.frame.height/2, width: 2*leftAxis.frame.height, height: 2*leftAxis.frame.height))
        leftAxisCircle.backgroundColor = specialElementColor
        leftAxisCircle.layer.cornerRadius = leftAxisCircle.frame.width/2
        leftAxis.addSubview(leftAxisCircle)

        
        //part of multiv view axis on right side
        let rightAxisSquare =  UIView(frame: CGRect(x: -leftAxis.frame.height, y: -leftAxis.frame.height, width: 2*leftAxis.frame.height, height: 2*leftAxis.frame.height))
        rightAxisSquare.backgroundColor = specialElementColor
        sideView.addSubview(rightAxisSquare)

        
        //floor planes
        for y in (1 ... numberOfFields).reversed(){
            for x in (1 ... numberOfFields).reversed(){
                let floor = PlanFloor(x: x, y: y)
                floor.isUserInteractionEnabled = false
                floor.translatesAutoresizingMaskIntoConstraints = true
                topView.addSubview(floor)
                floor.frame.size.width = fieldWidth
                floor.frame.size.height = fieldWidth
                floor.frame.origin = CGPoint(x: offset+CGFloat(floor.x-1)*fieldWidth, y: 0.5*fieldWidth+CGFloat(numberOfFields-floor.y)*fieldWidth)
                listOfFloors.append(floor)
            }
        }
        
        
        //colored axes
        if(coloredAxesAreEnabled){
            let xColoredAxes = UIView(frame: CGRect(x: fieldWidth, y: (0.5+CGFloat(numberOfFields)+0.1)*fieldWidth, width: CGFloat(numberOfFields)*fieldWidth, height: 0.9*fieldWidth))
            xColoredAxes.backgroundColor = xAxisColor
            topView.addSubview(xColoredAxes)
            
            let yColoredAxes = UIView(frame: CGRect(x: 0, y: 0.5*fieldWidth, width: 0.9*fieldWidth, height: CGFloat(numberOfFields)*fieldWidth))
            yColoredAxes.backgroundColor = yAxisColor
            topView.addSubview(yColoredAxes)

            let rightYColoredAxes = UIView(frame: CGRect(x: 0.5*fieldWidth, y: -2, width: CGFloat(numberOfFields)*fieldWidth, height: 4))
            rightYColoredAxes.backgroundColor = yAxisColor
            sideView.addSubview(rightYColoredAxes)
            let rightXColoredAxes = UIView(frame: CGRect(x: 0.6*fieldWidth+CGFloat(numberOfFields)*fieldWidth, y: -2, width: 0.9*fieldWidth, height: 4))
            rightXColoredAxes.backgroundColor = xAxisColor
            sideView.addSubview(rightXColoredAxes)
        }
        else{
            for i in 0 ..< numberOfFields{
                let rightFloorAxes = UIView(frame: CGRect(x: 0.5*fieldWidth+CGFloat(i)*fieldWidth, y: -2, width: fieldWidth, height: 4))
                rightFloorAxes.backgroundColor = ((numberOfFields-i)%2 == 0) ? darkFloorColor : lightFloorColor
                sideView.addSubview(rightFloorAxes)
            }
        }

        
        //axes numbers
        if(axesNumbersAreEnabled == true){
            for x in 1 ... numberOfFields{
                let xNumber = UILabel(frame: CGRect(x: CGFloat(x)*fieldWidth, y: (CGFloat(numberOfFields)+0.6)*fieldWidth, width: fieldWidth, height: 0.9*fieldWidth))
                xNumber.text = "\(x)"
                xNumber.textAlignment = .center
                xNumber.font = UIFont(name: "Menlo", size: fieldWidth/3)
                xNumber.textColor = coloredAxesAreEnabled ? systemBackgroundColor : xAxisColor
                topView.addSubview(xNumber)
            }
            for y in 1 ... numberOfFields{
                let yNumber = UILabel(frame: CGRect(x: 0, y: (0.5+CGFloat(numberOfFields-y))*fieldWidth, width: 0.9*fieldWidth, height: fieldWidth))
                yNumber.text = "\(y)"
                yNumber.textAlignment = .center
                yNumber.font = UIFont(name: "Menlo", size: fieldWidth/3)
                yNumber.textColor = coloredAxesAreEnabled ? systemBackgroundColor : yAxisColor
                topView.addSubview(yNumber)
            }
        }
        
        
        //shadows
        updateShadows()
    }
    

    func renewContent(){
        
        layoutIfNeeded()

        //transform all views
        let maxHeight = (leftContentView.bounds.height/2-20)/leftContentView.transform.a
        let maxWidth = leftContentView.bounds.width*CGFloat(numberOfFields+1)/CGFloat(numberOfFields+3)
        
        let realWidth = maxWidth*multiViewScaleFactor<maxHeight ? maxWidth : maxHeight/multiViewScaleFactor
        
        topView.transform.a = realWidth/1000
        topView.transform.d = realWidth/1000
        
        sideView.transform.a = realWidth/1000
        sideView.transform.d = realWidth/1000

        topView.center = CGPoint(x: leftContentView.bounds.width/2, y: leftContentView.bounds.height-20/rightContentView.transform.a)
        sideView.center = CGPoint(x: rightContentView.bounds.width/2, y: rightContentView.bounds.height-20/rightContentView.transform.a)
        
        
        //calc field width
        fieldWidth = (axesNumbersAreEnabled || coloredAxesAreEnabled) ? topView.bounds.width/CGFloat(numberOfFields+1) : topView.bounds.width/CGFloat(numberOfFields)
        offset = (axesNumbersAreEnabled || coloredAxesAreEnabled) ? fieldWidth : 0

        
        //create seperator lines
        let effectiveTopSpace = leftContentView.frame.origin.y+leftContentView.transform.a*topView.frame.origin.y
        let effectiveFloorWidth = topView.transform.a*leftContentView.transform.a*fieldWidth

        let numberOfSeperatorLines = Int(effectiveTopSpace/effectiveFloorWidth)+1
        
        for y in 1 ... numberOfSeperatorLines {
            let seperatorLine = UIView(frame: CGRect(x: offset-0.1*fieldWidth, y: -CGFloat(y)*fieldWidth-2, width: CGFloat(numberOfFields)*fieldWidth+0.2*fieldWidth, height: 4))
            seperatorLine.tag = y
            seperatorLine.backgroundColor = opaqueSeparatorColor
            
            
            let rightSeperatorLine = UIView(frame: CGRect(x: 0.4*fieldWidth, y: -CGFloat(y)*fieldWidth-2, width: CGFloat(numberOfFields)*fieldWidth+0.2*fieldWidth, height: 4))
            rightSeperatorLine.tag = y
            rightSeperatorLine.backgroundColor = opaqueSeparatorColor

            if(listOfSeperatorLines.filter({$0.tag == y}).isEmpty){
                listOfSeperatorLines += [seperatorLine]
                topView.addSubview(seperatorLine)
                topView.sendSubviewToBack(seperatorLine)
                
                sideView.addSubview(rightSeperatorLine)
                sideView.sendSubviewToBack(rightSeperatorLine)

                for x in 1 ... numberOfFields{
                    //front planes
                    let front = PlanFloor(x: x, y: y)
                    front.translatesAutoresizingMaskIntoConstraints = true
                    front.backgroundColor = .clear
                    front.frame.size.width = fieldWidth
                    front.frame.size.height = fieldWidth
                    front.frame.origin = CGPoint(x: offset+CGFloat(front.x-1)*fieldWidth, y: -CGFloat(front.y)*fieldWidth)
                    topView.addSubview(front)
                    listOfFrontShadows.append(front)

                    //side planes
                    let side = PlanFloor(x: x, y: y)
                    side.translatesAutoresizingMaskIntoConstraints = true
                    side.backgroundColor = .clear
                    side.frame.size.width = fieldWidth
                    side.frame.size.height = fieldWidth
                    side.frame.origin = CGPoint(x: 0.5*fieldWidth+CGFloat(numberOfFields-side.x)*fieldWidth, y: -CGFloat(side.y)*fieldWidth)
                    sideView.addSubview(side)
                    listOfSideShadows.append(side)
                }
                
            }
        }
        
        //bring information label to front
        self.bringSubviewToFront(informationLabel)
    }
    
        
    //when background is pinched
    @objc func zoomBackground(sender: UIPinchGestureRecognizer){
        
        leftContentView.transform = leftContentView.transform.scaledBy(x: sender.scale, y: sender.scale)
        rightContentView.transform = rightContentView.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
        
        if(leftContentView.transform.a < 0.5){
            leftContentView.transform.a = 0.5
            leftContentView.transform.d = 0.5
            rightContentView.transform.a = 0.5
            rightContentView.transform.d = 0.5
        }
        
        if(leftContentView.transform.a > 1){
            leftContentView.transform.a = 1
            leftContentView.transform.d = 1
            rightContentView.transform.a = 1
            rightContentView.transform.d = 1
        }
        
        renewContent()

        if(sender.state == .ended || sender.state == .cancelled){
            changeBackground()
        }
        
    }
    
    
    func changeBackground(){
        if(leftContentView.transform.a < 0.75){
            UIView.animate(withDuration: 0.2, animations: {
                self.leftContentView.transform.a = 0.5
                self.leftContentView.transform.d = 0.5
                self.rightContentView.transform.a = 0.5
                self.rightContentView.transform.d = 0.5

                self.renewContent()
            })
        }
        else{
            UIView.animate(withDuration: 0.2, animations: {
                self.leftContentView.transform.a = 1
                self.leftContentView.transform.d = 1
                self.rightContentView.transform.a = 1
                self.rightContentView.transform.d = 1

                self.renewContent()
            })
        }
    }
    
    
    func updateShadows(){
        
        //show or hide information label
        if(setOfCubes.filter({$0.z != 0 && ($0.x<=0 || $0.x>numberOfFields || $0.y<=0 || $0.y>numberOfFields)}).isEmpty){
            informationLabel.alpha = 0
        }
        else{
            informationLabel.alpha = 1
        }

        //remove all cubes
        for floor in listOfFloors{
            floor.backgroundColor = (floor.x+floor.y)%2==0 ? lightFloorColor : darkFloorColor
        }
        for front in listOfFrontShadows{
            front.backgroundColor = .clear
        }
        for side in listOfSideShadows{
            side.backgroundColor = .clear
        }
 
        //add visible cubes
        for cube in setOfCubes.filter({$0.z != 0 && $0.x>0 && $0.x<=numberOfFields && $0.y>0 && $0.y<=numberOfFields}){
            if let floor = listOfFloors.first(where: {$0.x == cube.x && $0.y == cube.y}){
                floor.backgroundColor = shadowColor
            }
            if let front = listOfFrontShadows.last(where: {$0.x == cube.x && $0.y == cube.z}){
                front.backgroundColor = shadowColor
            }
            if let side = listOfSideShadows.last(where: {$0.x == cube.y && $0.y == cube.z}){
                side.backgroundColor = shadowColor
            }
        }
    }

}
