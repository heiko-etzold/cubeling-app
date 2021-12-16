//
//  IsometricCube.swift
//  Cubeling
//
//  Created by Heiko Etzold on 10.08.15.
//  MIT License
//


import UIKit

class IsometricCube: UIView {

    var isoDistance = CGFloat(1)
    var x : Int!
    var y : Int!
    var z : Int!
    
    init(x: Int, y: Int, z: Int, size: CGFloat) {
        super.init(frame: .zero)
        
        self.backgroundColor = .clear

        self.frame.size.width = (lightMode == 0) ? size/tan(.pi/6)+CGFloat(4) :  size/tan(.pi/6)
        self.frame.size.height = (lightMode == 0) ? 2*size+CGFloat(4) : 2*size

        isoDistance = size
        self.x = x
        self.y = y
        self.z = z
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func draw(_ rect: CGRect) {
                
        let initPoint = (lightMode == 0) ? CGPoint(x: self.frame.width/2, y: self.frame.height-2) : CGPoint(x: self.frame.width/2, y: self.frame.height)
        
        let leftFace = UIGraphicsGetCurrentContext()!
        leftFace.setStrokeColor(scondaryLabelColor.cgColor)
        leftFace.setFillColor(sideColor.cgColor)
        leftFace.setLineWidth((lightMode == 0) ? 2 : 0)
        leftFace.setLineJoin(.round)
        leftFace.move(to: isometricView.isometricCoordinate(x: 0, y: 0, initPoint: initPoint, distance: isoDistance))
        leftFace.addLine(to: isometricView.isometricCoordinate(x: 1, y: 0, initPoint: initPoint, distance: isoDistance))
        leftFace.addLine(to: isometricView.isometricCoordinate(x: 2, y: 1, initPoint: initPoint, distance: isoDistance))
        leftFace.addLine(to: isometricView.isometricCoordinate(x: 1, y: 1, initPoint: initPoint, distance: isoDistance))
        leftFace.closePath()
        if(lightMode == 0){
            leftFace.drawPath(using: CGPathDrawingMode.fillStroke)
        }
        else{
            leftFace.drawPath(using: CGPathDrawingMode.fill)
        }
        
        let rightFace = UIGraphicsGetCurrentContext()!
        rightFace.setStrokeColor(scondaryLabelColor.cgColor)
        rightFace.setFillColor(sideColor.cgColor)
        rightFace.setLineWidth((lightMode == 0) ? 2 : 0)
        rightFace.setLineJoin(.round)
        rightFace.move(to: isometricView.isometricCoordinate(x: 0, y: 0, initPoint: initPoint, distance: isoDistance))
        rightFace.addLine(to: isometricView.isometricCoordinate(x: 0, y: 1, initPoint: initPoint, distance: isoDistance))
        rightFace.addLine(to: isometricView.isometricCoordinate(x: 1, y: 2, initPoint: initPoint, distance: isoDistance))
        rightFace.addLine(to: isometricView.isometricCoordinate(x: 1, y: 1, initPoint: initPoint, distance: isoDistance))
        rightFace.closePath()
        if(lightMode == 0){
            rightFace.drawPath(using: CGPathDrawingMode.fillStroke)
        }
        else{
            rightFace.drawPath(using: CGPathDrawingMode.fill)
        }
        
        let topFace = UIGraphicsGetCurrentContext()!
        topFace.setStrokeColor(scondaryLabelColor.cgColor)
        topFace.setFillColor(topColor.cgColor)
        topFace.setLineWidth((lightMode == 0) ? 2 : 0)
        topFace.setLineJoin(.round)
        topFace.move(to: isometricView.isometricCoordinate(x: 1, y: 1, initPoint: initPoint, distance: isoDistance))
        topFace.addLine(to: isometricView.isometricCoordinate(x: 2, y: 1, initPoint: initPoint, distance: isoDistance))
        topFace.addLine(to: isometricView.isometricCoordinate(x: 2, y: 2, initPoint: initPoint, distance: isoDistance))
        topFace.addLine(to: isometricView.isometricCoordinate(x: 1, y: 2, initPoint: initPoint, distance: isoDistance))
        topFace.closePath()
        if(lightMode == 0){
            topFace.drawPath(using: CGPathDrawingMode.fillStroke)
        }
        else{
            topFace.drawPath(using: CGPathDrawingMode.fill)
        }
    }
}
