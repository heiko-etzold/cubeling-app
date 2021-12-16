//
//  CavalierViewCube.swift
//  Cubeling
//
//  Created by Heiko Etzold on 23.08.20.
//  GNU GPLv3
//


import UIKit


class CavalierCube: UIView {

    let cubeBorderWidth = CGFloat(2)

    var x : Int!
    var y : Int!
    var z : Int!
    
    init(x: Int, y: Int, z: Int) {
        super.init(frame: .zero)
        
        self.x = x
        self.y = y
        self.z = z

        //add "drawn" cube and set size of it
        let drawView = CavalierViewCubeDraw(borderWidth: 2)
        drawView.backgroundColor = .clear
        self.addSubview(drawView)
        drawView.translatesAutoresizingMaskIntoConstraints = false
        drawView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1+sqrt(2)/4, constant: cubeBorderWidth).isActive = true
        drawView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1+sqrt(2)/4, constant: cubeBorderWidth).isActive = true
        drawView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: -cubeBorderWidth/2).isActive = true
        drawView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: cubeBorderWidth/2).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}



class CavalierViewCubeDraw: UIView {
    
    var cubeBorderWidth = CGFloat(2)
    
    init(borderWidth: CGFloat) {
        super.init(frame: CGRect.zero)
        cubeBorderWidth = borderWidth
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draw(_ rect: CGRect) {

        let cubeWidth = self.frame.width/(1+sqrt(2)/4)
        let viewWidth = self.frame.width
        let sideWidth = cubeWidth*sqrt(2)/4

        
        let frontFace = UIGraphicsGetCurrentContext()!
        frontFace.setLineWidth(cubeBorderWidth)
        frontFace.setLineJoin(.round)
        frontFace.setStrokeColor(labelColor.cgColor)
        frontFace.setFillColor(sideColor.cgColor)
        frontFace.move(to: CGPoint(x: cubeBorderWidth/2, y: sideWidth+cubeBorderWidth/2))
        frontFace.addLine(to: CGPoint(x: cubeWidth, y: sideWidth+cubeBorderWidth/2))
        frontFace.addLine(to: CGPoint(x: cubeWidth, y: viewWidth-cubeBorderWidth/2))
        frontFace.addLine(to: CGPoint(x: cubeBorderWidth/2, y: viewWidth-cubeBorderWidth/2))
        frontFace.closePath()
        frontFace.drawPath(using: CGPathDrawingMode.fillStroke)

        
        let topFace = UIGraphicsGetCurrentContext()!
        topFace.setLineWidth(cubeBorderWidth)
        topFace.setLineJoin(.round)
        topFace.setStrokeColor(labelColor.cgColor)
        topFace.setFillColor(topColor.cgColor)
        topFace.move(to: CGPoint(x: cubeBorderWidth/2, y: sideWidth+cubeBorderWidth/2))
        topFace.addLine(to: CGPoint(x: cubeWidth, y: sideWidth+cubeBorderWidth/2))
        topFace.addLine(to: CGPoint(x: viewWidth-cubeBorderWidth/2, y: cubeBorderWidth/2))
        topFace.addLine(to: CGPoint(x: sideWidth, y: cubeBorderWidth/2))
        topFace.closePath()
        topFace.drawPath(using: CGPathDrawingMode.fillStroke)

        
        let rightFace = UIGraphicsGetCurrentContext()!
        rightFace.setLineWidth(cubeBorderWidth)
        rightFace.setLineJoin(.round)
        rightFace.setStrokeColor(labelColor.cgColor)
        rightFace.setFillColor(sideColor.cgColor)
        rightFace.move(to: CGPoint(x: cubeWidth, y: sideWidth+cubeBorderWidth/2))
        rightFace.addLine(to: CGPoint(x: viewWidth-cubeBorderWidth/2, y: cubeBorderWidth/2))
        rightFace.addLine(to: CGPoint(x: viewWidth-cubeBorderWidth/2, y: cubeWidth))
        rightFace.addLine(to: CGPoint(x: cubeWidth, y: viewWidth-cubeBorderWidth/2))
        rightFace.closePath()
        rightFace.drawPath(using: CGPathDrawingMode.fillStroke)
    }
    
    override func layoutSubviews() {
        let cubeWidth = (self.frame.width)/(1+sqrt(2)/4)
        let viewWidth = self.frame.width
        let sideWidth = cubeWidth*sqrt(2)/4
        
        
        let myClippingPath = UIBezierPath()
        myClippingPath.move(to: CGPoint(x: sideWidth, y: 0))
        myClippingPath.addLine(to: CGPoint(x: viewWidth, y: 0))
        myClippingPath.addLine(to: CGPoint(x: viewWidth, y: cubeWidth))
        myClippingPath.addLine(to: CGPoint(x: cubeWidth, y: viewWidth))
        myClippingPath.addLine(to: CGPoint(x: 0, y: viewWidth))
        myClippingPath.addLine(to: CGPoint(x: 0, y: sideWidth))
        myClippingPath.close()
        
        
        let mask = CAShapeLayer()
        mask.path = myClippingPath.cgPath
        self.layer.mask = mask
    }
    
}
