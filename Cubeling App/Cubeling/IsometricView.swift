//
//  IsometricView.swift
//  Cubeling
//
//  Created by Heiko Etzold on 09.08.15.
//  MIT License
//


import UIKit
import SceneKit

class IsometricView: UIView {

    var initPoint = CGPoint.zero
    var isometricDistance = CGFloat(1)
    
    let informationLabel = UILabel()

    var contentView = UIView()
    var setOfIsometricCubes : Set<IsometricCube> = []
    var listOfIsometricCubes : [IsometricCube] = []
    var listOfDots: [UIView] = []

    let isoaxis = UIView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = systemBackgroundColor

        informationLabel.numberOfLines = -1
        informationLabel.text = "HintLabelText".localized()

        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        
        createContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    func isometricCoordinate(x: CGFloat, y: CGFloat, initPoint: CGPoint, distance: CGFloat) -> CGPoint{
        return CGPoint(x: initPoint.x+x*distance*cos(.pi/6)+y*distance*cos(.pi*5/6),
                       y: initPoint.y-x*distance*sin(.pi/6)-y*distance*sin(.pi*5/6))
    }

    func cartesianCoordinate(isoX: CGFloat, isoY: CGFloat, initPoint: CGPoint, distance: CGFloat) -> CGPoint{
        let x = (sin(.pi*5/6)*isoX+cos(.pi*5/6)*isoY-sin(.pi*5/6)*initPoint.x-cos(.pi*5/6)*initPoint.y)/(distance*(sin(.pi*5/6)*cos(.pi/6)-cos(.pi*5/6)*sin(.pi/6)))
        let y = (sin(.pi/6)*isoX+cos(.pi/6)*isoY-sin(.pi/6)*initPoint.x-cos(.pi/6)*initPoint.y)/(distance*(sin(.pi/6)*cos(.pi*5/6)-cos(.pi/6)*sin(.pi*5/6)))
        return CGPoint(x: x, y: y)
    }

    //     isoX = initPoint.x + x*distance*cos(.pi/6) + y*distance*cos(.pi*5/6)
    //     isoY = initPoint.y - x*distance*sin(.pi/6) - y*distance*sin(.pi*5/6)
    
    
    
    
    func createContent(){

        //remove all subview
        for subview in self.subviews{
            subview.removeFromSuperview()
        }
        listOfIsometricCubes = []
        
        //information, when cube is outside the grid
        self.addSubview(informationLabel)
        informationLabel.translatesAutoresizingMaskIntoConstraints = false
        informationLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        informationLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        informationLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true

        //content view for fields and cubes
        contentView = UIView()
        self.addSubview(contentView)
        contentView.frame.size.width = 1000
        contentView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        if(axesNumbersAreEnabled || coloredAxesAreEnabled){
            contentView.frame.size.height = contentView.frame.width*(CGFloat(numberOfFields)+0.5)/(CGFloat(numberOfFields)+1)*tan(.pi/6)
        }
        else{
            contentView.frame.size.height = contentView.frame.width*tan(.pi/6)
        }
        
        
        renewContent()

        
        //floor planes
        for x in 1 ... numberOfFields{
            for y in 1 ... numberOfFields{
                let floor = UIView(frame: CGRect(x: 0, y: 0, width: isometricDistance/sqrt(2), height: isometricDistance/sqrt(2)))
                floor.center = isometricCoordinate(x: CGFloat(x), y: CGFloat(y), initPoint: initPoint, distance: isometricDistance)
                floor.backgroundColor = (x+y)%2==0 ? lightFloorColor : darkFloorColor
                floor.transform = CGAffineTransform.init(rotationAngle: .pi/4).concatenating(CGAffineTransform.init(scaleX: 1/tan(.pi/6), y: 1))
                contentView.addSubview(floor)
                contentView.sendSubviewToBack(floor)
            }
        }
        

        //colored axes
        if(coloredAxesAreEnabled){
            let coloredXAxis = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(numberOfFields)*isometricDistance/sqrt(2), height: 0.9*isometricDistance/sqrt(2)))
            coloredXAxis.center = isometricCoordinate(x: CGFloat(numberOfFields)/2+0.5, y: -0.05, initPoint: initPoint, distance: isometricDistance)
            coloredXAxis.backgroundColor = xAxisColor
            coloredXAxis.transform = CGAffineTransform.init(rotationAngle: -.pi/4).concatenating(CGAffineTransform.init(scaleX: 1/tan(.pi/6), y: 1))
            contentView.addSubview(coloredXAxis)
            
            let coloredYAxis = UIView(frame: CGRect(x: 0, y: 0, width: 0.9*isometricDistance/sqrt(2), height: CGFloat(numberOfFields)*isometricDistance/sqrt(2)))
            coloredYAxis.center = isometricCoordinate(x: -0.05, y: CGFloat(numberOfFields)/2+0.5, initPoint: initPoint, distance: isometricDistance)
            coloredYAxis.backgroundColor = yAxisColor
            coloredYAxis.transform = CGAffineTransform.init(rotationAngle: -.pi/4).concatenating(CGAffineTransform.init(scaleX: 1/tan(.pi/6), y: 1))
            contentView.addSubview(coloredYAxis)
        }
        
        
        //axes numbers
        if(axesNumbersAreEnabled){
            for x in 1 ... numberOfFields{
                let xNumber = UILabel(frame: CGRect(x: 0, y: 0, width: isometricDistance/sqrt(2), height: 0.9*isometricDistance/sqrt(2)))
                xNumber.text = "\(x)"
                xNumber.textAlignment = .center
                xNumber.font = UIFont(name: "Menlo", size: isometricDistance/sqrt(2)/3)
                xNumber.textColor = coloredAxesAreEnabled ? systemBackgroundColor : xAxisColor
                xNumber.center = isometricCoordinate(x: CGFloat(x), y: CGFloat(-0.05), initPoint: initPoint, distance: isometricDistance)
                xNumber.transform = CGAffineTransform.init(rotationAngle: -.pi/4).concatenating(CGAffineTransform.init(scaleX: 1/tan(.pi/6), y: 1))
                contentView.addSubview(xNumber)
            }
            for y in 1 ... numberOfFields{
                let yNumber = UILabel(frame: CGRect(x: 0, y: 0, width: 0.9*isometricDistance/sqrt(2), height: 0.5*isometricDistance/sqrt(2)))
                yNumber.text = "\(y)"
                yNumber.textAlignment = .center
                yNumber.font = UIFont(name: "Menlo", size: isometricDistance/sqrt(2)/3)
                yNumber.textColor = coloredAxesAreEnabled ? systemBackgroundColor : yAxisColor
                yNumber.center = isometricCoordinate(x: CGFloat(-0.05), y: CGFloat(y), initPoint: initPoint, distance: isometricDistance)
                yNumber.transform = CGAffineTransform.init(rotationAngle: -.pi/4).concatenating(CGAffineTransform.init(scaleX: 1/tan(.pi/6), y: 1))
                contentView.addSubview(yNumber)
            }
        }
            
        updateCubes()

    }
    

    func renewContent(){
        
        //adjust all sizes
        layoutIfNeeded()
        let realWidth = self.frame.width-40
        
        contentView.transform.a = realWidth/1000
        contentView.transform.d = realWidth/1000
        
        contentView.center = CGPoint(x: self.bounds.width/2, y: self.bounds.height-20)
        
        
        isometricDistance = (axesNumbersAreEnabled || coloredAxesAreEnabled) ? contentView.bounds.width/CGFloat(numberOfFields+1)*tan(.pi/6) : contentView.bounds.width/CGFloat(numberOfFields)*tan(.pi/6)
        initPoint = (axesNumbersAreEnabled || coloredAxesAreEnabled) ? CGPoint(x: contentView.bounds.width/2, y: contentView.bounds.height) : CGPoint(x: contentView.bounds.width/2, y: contentView.bounds.height+isometricDistance/2)

        
        //calc borders for dots
        let upperLeft = cartesianCoordinate(isoX: -contentView.frame.origin.x/contentView.transform.a, isoY: -contentView.frame.origin.y/contentView.transform.a, initPoint: initPoint, distance: isometricDistance)
        let upperIso = Int(max(upperLeft.x,upperLeft.y))+1

        let bottomSpace = self.frame.height-contentView.frame.origin.y-contentView.frame.height
        let lowerLeft = cartesianCoordinate(isoX: -contentView.frame.origin.x/contentView.transform.a, isoY: contentView.bounds.height+bottomSpace/contentView.transform.a, initPoint: initPoint, distance: isometricDistance)
        var lowerIso = Int(min(lowerLeft.x,lowerLeft.y))-1
        if(lowerIso>=upperIso){
            lowerIso = upperIso-1
        }
        
        
        //dots background
        for dot in listOfDots{
            dot.removeFromSuperview()
        }
        for i in lowerIso ... upperIso{
            for j in lowerIso ... upperIso{
                let muh = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
                muh.layer.cornerRadius = 2
                muh.center = isometricCoordinate(x: CGFloat(i)-0.5, y: CGFloat(j)-0.5, initPoint: initPoint, distance: isometricDistance)
                muh.backgroundColor = scondaryLabelColor
                contentView.addSubview(muh)
                listOfDots.append(muh)
            }
        }

        
        //isometric axis
        isoaxis.frame = CGRect(x: 0, y: 0, width: 4, height: isometricDistance)
        isoaxis.layer.cornerRadius = 2
        isoaxis.backgroundColor = specialElementColor
        isoaxis.center = isometricCoordinate(x: 3, y: 3, initPoint: initPoint, distance: isometricDistance)
        contentView.addSubview(isoaxis)
        
        let maximumHeightNumber = Int(self.frame.height/isometricDistance/contentView.transform.a)+1
        print(maximumHeightNumber)
        
        //draw all cubes
        for z in 1 ... maximumHeightNumber{
            if(listOfIsometricCubes.filter({$0.z == z}).isEmpty){
                for y in (1 ... numberOfFields).reversed(){
                    for x in (1 ... numberOfFields).reversed(){
                        let isometricCube = IsometricCube(x: x, y: y, z: z, size: isometricDistance)
                        isometricCube.center = isometricCoordinate(x: CGFloat(x+(z-1))+0.5, y: CGFloat(y+(z-1))+0.5, initPoint: initPoint, distance: isometricDistance)
                        contentView.addSubview(isometricCube)
                        listOfIsometricCubes.append(isometricCube)
                    }
                }
            }
        }
        
    }

    
    func updateCubes(){

        //show or hide information label
        if(setOfCubes.filter({$0.z != 0 && ($0.x<=0 || $0.x>numberOfFields || $0.y<=0 || $0.y>numberOfFields)}).isEmpty){
            informationLabel.alpha = 0
        }
        else{
            informationLabel.alpha = 1
        }
 
        
        //remove all cubes
        for cu in listOfIsometricCubes{
            cu.alpha = 0
        }
        
        //add visible cubes
        for cube in setOfCubes.filter({$0.z != 0 && $0.x>0 && $0.x<=numberOfFields && $0.y>0 && $0.y<=numberOfFields}){
            if let cu = listOfIsometricCubes.last(where: {$0.x == cube.x && $0.y == cube.y && $0.z == cube.z}){
                cu.alpha = 1
            }
        }
        
        
        //bring isometric axis to front if necessary
        if setOfCubes.filter({($0.x == 2 && $0.y == 2 && $0.z == 1) || ($0.x <= 2 && $0.y <= 2 && $0.z > 1)}).isEmpty{
            contentView.bringSubviewToFront(isoaxis)
        }
        else{
            contentView.sendSubviewToBack(isoaxis)
        }
    }
}
