//
//  CodeRunView.swift
//  Cubeling
//
//  Created by Heiko Etzold on 28.05.17.
//  MIT License
//

import UIKit

class CodeTracingView: UIView {
    
    let currentActionCirlce = UIView()
    var squareSize = CGFloat(4)

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        currentActionCirlce.frame.size = CGSize(width: 2*codeLineHeight/3, height: 2*codeLineHeight/3)
        currentActionCirlce.center = CGPoint(x: tracingViewWidth/2, y: -codeLineHeight/2-codeLineHeight/3)
        currentActionCirlce.backgroundColor = .clear
        
        currentActionCirlce.layer.borderColor = labelColor.cgColor
        currentActionCirlce.layer.borderWidth = 1
        currentActionCirlce.layer.cornerRadius = codeLineHeight/3
        self.addSubview(currentActionCirlce)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    func widthByLoopDepth(depth: Int) -> CGFloat{
        print(currentActionCirlce.frame)
        return tracingViewWidth/2-currentActionCirlce.bounds.width/2-10-5*CGFloat(depth)
    }
    
    
    override func draw(_ rect: CGRect) {

        let lines = UIGraphicsGetCurrentContext()!
        lines.setStrokeColor(labelColor.cgColor)


        lines.move(to: CGPoint(x: tracingViewWidth/2-5, y: codeLineHeight/2))
        lines.addLine(to: CGPoint(x: tracingViewWidth/2+5, y: codeLineHeight/2))
        lines.move(to: CGPoint(x: tracingViewWidth/2, y: codeLineHeight/2))
        lines.addLine(to: CGPoint(x: tracingViewWidth/2, y: codeLineHeight))


        
        for subview in self.subviews.filter({$0 != currentActionCirlce}){
            subview.removeFromSuperview()
        }
        

        for line in setOfCodeLines{

            let allStartLines = setOfCodeLines.filter({$0 is CodeLineLoopStart})
            var drawSpecialLines = Bool(true)
            for startLine in allStartLines{
                if(startLine.listOfValues[0].value == 0 && (startLine as! CodeLineLoopStart).setOfFixedCodeLines.contains(line)){
                    drawSpecialLines = false
                }
            }
            if(line is CodeLineLoopEnd && drawSpecialLines == true){
                lines.move(to: CGPoint(x: tracingViewWidth/2, y: line.frame.origin.y+codeLineHeight))
                lines.addLine(to: CGPoint(x: tracingViewWidth/2, y: line.frame.origin.y+3*codeLineHeight/2))
                lines.addLine(to: CGPoint(x: tracingViewWidth/2-codeLineHeight/4, y: line.frame.origin.y+7*codeLineHeight/4))
                lines.addLine(to: CGPoint(x: tracingViewWidth/2, y: line.frame.origin.y+2*codeLineHeight))
                
                lines.move(to: CGPoint(x: tracingViewWidth/2, y: line.frame.origin.y+3*codeLineHeight/2))
                lines.addLine(to: CGPoint(x: tracingViewWidth/2+codeLineHeight/4, y: line.frame.origin.y+7*codeLineHeight/4))
                let width = widthByLoopDepth(depth: line.loopDepth)

                lines.addLine(to: CGPoint(x: tracingViewWidth/2+width, y: line.frame.origin.y+7*codeLineHeight/4))
                let connectedStartLine = setOfCodeLines.first(where: {$0 is CodeLineLoopStart && ($0 as! CodeLineLoopStart).connectedEndLine == line})!
                lines.addLine(to: CGPoint(x: tracingViewWidth/2+width, y: connectedStartLine.frame.origin.y+3*codeLineHeight/2))
                lines.addLine(to: CGPoint(x: tracingViewWidth/2, y: connectedStartLine.frame.origin.y+3*codeLineHeight/2))

            }
            else{
                lines.move(to: CGPoint(x: tracingViewWidth/2, y: line.frame.origin.y+codeLineHeight))
                lines.addLine(to: CGPoint(x: tracingViewWidth/2, y: line.frame.origin.y+2*codeLineHeight))
            }
        }
        
        lines.move(to: CGPoint(x: tracingViewWidth/2, y: CGFloat(setOfCodeLines.count+1)*codeLineHeight))
        lines.addLine(to: CGPoint(x: tracingViewWidth/2, y: (CGFloat(setOfCodeLines.count)+1.5)*codeLineHeight))

        lines.move(to: CGPoint(x: tracingViewWidth/2-5, y: (CGFloat(setOfCodeLines.count)+1.5)*codeLineHeight))
        lines.addLine(to: CGPoint(x: tracingViewWidth/2+5, y: (CGFloat(setOfCodeLines.count)+1.5)*codeLineHeight))

        
        lines.setLineWidth(1)
        lines.strokePath()

        
        let squares = UIGraphicsGetCurrentContext()!
        for line in setOfCodeLines{

            let allStartLines = setOfCodeLines.filter({$0 is CodeLineLoopStart})
            var drawSquares = Bool(true)
            for startLine in allStartLines{
                if(startLine.listOfValues[0].value == 0 && (startLine as! CodeLineLoopStart).setOfFixedCodeLines.contains(line)){
                    drawSquares = false
                }
            }
            for value in line.listOfValues{
                if(!value.valueIsSet){
                    drawSquares = false
                }
            }
            
            if(drawSquares == true){
            if(line is CodeLineLoopEnd){

                squares.setFillColor(UIColor.systemRed.cgColor)

                squares.fillEllipse(in: CGRect(x: tracingViewWidth/2-squareSize, y: line.frame.origin.y+3*codeLineHeight/2-squareSize, width: 2*squareSize, height: 2*squareSize))

                
                let connectedStartLine = setOfCodeLines.first(where: {$0 is CodeLineLoopStart && ($0 as! CodeLineLoopStart).connectedEndLine == line})! as! CodeLineLoopStart

                if(connectedStartLine.currentTracingStep < connectedStartLine.listOfValues[0].value){
                    squares.move(to: CGPoint(x: tracingViewWidth/2+sqrt(2)*squareSize/2, y: line.frame.origin.y+3*codeLineHeight/2-sqrt(2)*squareSize/2))
                    squares.addLine(to: CGPoint(x: tracingViewWidth/2+2*squareSize, y: line.frame.origin.y+3*codeLineHeight/2+2*squareSize))
                    squares.addLine(to: CGPoint(x: tracingViewWidth/2-sqrt(2)*squareSize/2, y: line.frame.origin.y+3*codeLineHeight/2+sqrt(2)*squareSize/2))
                }
                

                if(connectedStartLine.currentTracingStep >= connectedStartLine.listOfValues[0].value){
                    squares.move(to: CGPoint(x: tracingViewWidth/2-sqrt(2)*squareSize/2, y: line.frame.origin.y+3*codeLineHeight/2-sqrt(2)*squareSize/2))
                    squares.addLine(to: CGPoint(x: tracingViewWidth/2-2*squareSize, y: line.frame.origin.y+3*codeLineHeight/2+2*squareSize))
                    squares.addLine(to: CGPoint(x: tracingViewWidth/2+sqrt(2)*squareSize/2, y: line.frame.origin.y+3*codeLineHeight/2+sqrt(2)*squareSize/2))
                }
                squares.fillPath()
                
                if(!unloopedCodeLines.isEmpty && codeView.currentCodeStep >= 0 && codeView.currentCodeStep < unloopedCodeLines.count &&   connectedStartLine.setOfFixedCodeLines.contains(unloopedCodeLines[codeView.currentCodeStep])){
                    let label = UILabel(frame: CGRect(x: 0, y: connectedStartLine.frame.origin.y+codeLineHeight, width: tracingViewWidth/2-codeLineHeight/3-5, height: codeLineHeight))
                    label.textAlignment = .right
                    label.text = "\(connectedStartLine.currentTracingStep) \(NSLocalizedString("CodeLoopOf", comment: "CodeLoopOf")) \(connectedStartLine.listOfValues[0].value)"
                    label.textColor = UIColor.systemRed
                    label.font = label.font.withSize(codeLineHeight/3)
                    self.addSubview(label)
                    
                }
            }
            else{
                squares.setFillColor((line is CodeLineLoopStart) ? UIColor.systemRed.cgColor : labelColor.cgColor)
                squares.fillEllipse(in: CGRect(x: tracingViewWidth/2-squareSize, y: line.frame.origin.y+3*codeLineHeight/2-squareSize, width: 2*squareSize, height: 2*squareSize))
                }
            }
        }        
    }

    
}

