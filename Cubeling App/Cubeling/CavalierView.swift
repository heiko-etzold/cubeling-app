//
//  CavalierView.swift
//  Cubeling
//
//  Created by Heiko Etzold on 08.08.15.
//  MIT License
//


import UIKit

class CavalierView: UIView {
            
    var floorHeight = CGFloat(1)
    var floorWidth = CGFloat(1)
    var leftOffset = CGFloat(0)
    var bottomOffset = CGFloat(0)
    
    let informationLabel = UILabel()

    var contenView = UIView()
    var setOfCavalierCubes : Set<CavalierCube> = []
    var listOfCavalierCubes : [CavalierCube] = []

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = systemBackgroundColor

        createContent()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func createContent(){

        //remove all subview
        for subview in self.subviews{
            subview.removeFromSuperview()
        }
        
        //empty set of cubes
        setOfCavalierCubes = []
        listOfCavalierCubes = []

        //information, when cube is outside the grid
        self.addSubview(informationLabel)
        informationLabel.translatesAutoresizingMaskIntoConstraints = false
        informationLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        informationLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        informationLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        informationLabel.numberOfLines = -1
        informationLabel.text = "HintLabelText".localized()


        //content view for fields and cubes
        contenView = UIView()
        contenView.backgroundColor = .clear
        self.addSubview(contenView)
        contenView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        contenView.frame.size.width = 1000
        if(axesNumbersAreEnabled || coloredAxesAreEnabled){
            contenView.frame.size.height = contenView.frame.width*(CGFloat(numberOfFields)+1)/((CGFloat(numberOfFields)+1)*sqrt(8)+CGFloat(numberOfFields))
        }
        else{
            contenView.frame.size.height = contenView.frame.width/(1+sqrt(8))
        }
        

        renewContent()

        
        //floor planes
        for x in 0 ..< numberOfFields{
            for y in 0 ..< numberOfFields{
                let floor = UIView()
                floor.backgroundColor = (x+y)%2==0 ? lightFloorColor : darkFloorColor
                floor.frame = CGRect(x: leftOffset+CGFloat(x)*floorWidth+CGFloat(y)*floorHeight, y: contenView.bounds.height-bottomOffset-CGFloat(y+1)*floorHeight, width: floorWidth, height: floorHeight)
                floor.setAnchorPoint(CGPoint(x: 0, y: 1))
                floor.transform = CGAffineTransform(a: 1, b: 0, c: -1, d: 1, tx: 0, ty: 0)
                contenView.addSubview(floor)
                contenView.sendSubviewToBack(floor)
            }
        }
        
        
        
        
        
        //axes numbers
        if(axesNumbersAreEnabled == true){
            for x in 1 ... numberOfFields{
                let xNumber = UILabel(frame : CGRect(x: CGFloat(x)*floorWidth-floorHeight, y: contenView.bounds.height-0.9*floorHeight, width: floorWidth, height: 0.9*floorHeight))
                xNumber.text = "\(x)"
                xNumber.textAlignment = .center
                xNumber.font = UIFont(name: "Menlo", size: floorHeight/2)
                xNumber.textColor = coloredAxesAreEnabled ? systemBackgroundColor : xAxisColor
                xNumber.setAnchorPoint(CGPoint(x: 0, y: 1))
                xNumber.transform = CGAffineTransform(a: 1, b: 0, c: -1, d: 1, tx: 0, ty: 0)
                contenView.addSubview(xNumber)
                contenView.sendSubviewToBack(xNumber)

            }
            for y in 1 ... numberOfFields{
                let yNumber = UILabel(frame : CGRect(x: CGFloat(y-1)*floorHeight, y: contenView.bounds.height-bottomOffset-CGFloat(y)*floorHeight, width: 0.9*floorWidth, height: floorHeight))
                yNumber.text = "\(y)"
                yNumber.textAlignment = .center
                yNumber.font = UIFont(name: "Menlo", size: floorHeight/2)
                yNumber.textColor = coloredAxesAreEnabled ? systemBackgroundColor : yAxisColor
                yNumber.setAnchorPoint(CGPoint(x: 0, y: 1))
                yNumber.transform = CGAffineTransform(a: 1, b: 0, c: -1, d: 1, tx: 0, ty: 0)
                contenView.addSubview(yNumber)
                contenView.sendSubviewToBack(yNumber)
            }
        }
        
        //colored axes
        if(coloredAxesAreEnabled){
            let xColoredAxes = UIView(frame: CGRect(x: floorWidth-floorHeight, y: contenView.bounds.height-0.9*floorHeight, width: CGFloat(numberOfFields)*floorWidth, height: 0.9*floorHeight))
            xColoredAxes.backgroundColor = xAxisColor
            contenView.addSubview(xColoredAxes)
            contenView.sendSubviewToBack(xColoredAxes)
            xColoredAxes.setAnchorPoint(CGPoint(x: 0, y: 1))
            xColoredAxes.transform = CGAffineTransform(a: 1, b: 0, c: -1, d: 1, tx: 0, ty: 0)

            let yColoredAxes = UIView(frame: CGRect(x: 0, y: 0, width: 0.9*floorWidth, height: CGFloat(numberOfFields)*floorHeight))
            yColoredAxes.backgroundColor = yAxisColor
            contenView.addSubview(yColoredAxes)
            contenView.sendSubviewToBack(yColoredAxes)
            yColoredAxes.setAnchorPoint(CGPoint(x: 0, y: 1))
            yColoredAxes.transform = CGAffineTransform(a: 1, b: 0, c: -1, d: 1, tx: 0, ty: 0)
        }

        updateCavalierCubes()
    }
    
    
    func renewContent(){

        //adjust all sizes
        layoutIfNeeded()

        let realWidth = self.frame.width-40
        
        contenView.transform.a = realWidth/1000
        contenView.transform.d = realWidth/1000
        
        contenView.center = CGPoint(x: self.bounds.width/2, y: self.bounds.height-20)
        
        
        //calc floor sizes and offset values
        floorHeight = (axesNumbersAreEnabled || coloredAxesAreEnabled) ? contenView.bounds.height/CGFloat(numberOfFields+1) : contenView.bounds.height/CGFloat(numberOfFields)
        floorWidth = floorHeight*sqrt(8)

        leftOffset = (axesNumbersAreEnabled || coloredAxesAreEnabled) ? floorWidth : 0
        bottomOffset = (axesNumbersAreEnabled || coloredAxesAreEnabled) ? floorHeight : 0
        
        let maximumHeightNumber = Int(self.frame.height/floorWidth/contenView.transform.a)+1

        //draw all cubes
        for z in 1 ... maximumHeightNumber{
            if(listOfCavalierCubes.filter({$0.z == z}).isEmpty){
                for y in (1 ... numberOfFields).reversed(){
                    for x in 1 ... numberOfFields{
                        let cu = CavalierCube(x: x, y: y, z: z)
                        cu.frame.size.height = floorWidth
                        cu.frame.origin = CGPoint(x: leftOffset+CGFloat(x-1)*floorWidth+CGFloat(y-1)*floorHeight, y: contenView.bounds.height-bottomOffset-CGFloat(z)*floorWidth-CGFloat(y-1)*floorHeight)
                        contenView.addSubview(cu)
                        cu.alpha = 0
                        listOfCavalierCubes.append(cu)
                    }
                }
            }
        }
        
    }
    
    
    func updateCavalierCubes(){
        
        //show or hide information label
        if(setOfCubes.filter({$0.z != 0 && ($0.x<=0 || $0.x>numberOfFields || $0.y<=0 || $0.y>numberOfFields)}).isEmpty){
            informationLabel.alpha = 0
        }
        else{
            informationLabel.alpha = 1
        }
        
        //remove all cubes
        for cu in listOfCavalierCubes{
            cu.alpha = 0
        }
        
        //add visible cubes
        for cube in setOfCubes.filter({$0.z != 0 && $0.x>0 && $0.x<=numberOfFields && $0.y>0 && $0.y<=numberOfFields}){
            if let cu = listOfCavalierCubes.last(where: {$0.x == cube.x && $0.y == cube.y && $0.z == cube.z}){
                cu.alpha = 1
            }
        }

        
    }
}
