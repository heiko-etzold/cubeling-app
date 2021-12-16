//
//  CodeScrollView.swift
//  Cubeling
//
//  Created by Heiko Etzold on 08.08.20.
//  MIT License
//

import UIKit

class StrokesBetweenCodeLinesView: UIView {


    var exceptLineNumbers : [Int] = []
    var linesAreVisible = Bool(false)
    
    func renewLines(exceptLines: [Int]){
        linesAreVisible = true
        exceptLineNumbers = exceptLines
        self.setNeedsDisplay()
    }
    
    func clearLines(){
        linesAreVisible = false
        self.setNeedsDisplay()

    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        self.backgroundColor = .clear
        if(linesAreVisible){
            let separatorLine = UIGraphicsGetCurrentContext()!
            separatorLine.setStrokeColor(UITableView().separatorColor!.cgColor)
            
            for line in setOfCodeLines.filter({!exceptLineNumbers.contains($0.lineNumber) && $0.lineNumber != setOfCodeLines.count}){
                
                var offset = CGFloat(0)
                if(line is CodeLineLoopStart){
                    offset = 20
                }
                separatorLine.move(to: CGPoint(x: 5, y: CGFloat(line.lineNumber)*codeLineHeight))
                separatorLine.addLine(to: CGPoint(x: offset+20+CGFloat(line.loopDepth)*20, y: CGFloat(line.lineNumber)*codeLineHeight))
                separatorLine.addLine(to: CGPoint(x: offset+30+CGFloat(line.loopDepth)*20, y: CGFloat(line.lineNumber)*codeLineHeight+5))
                separatorLine.addLine(to: CGPoint(x: offset+40+CGFloat(line.loopDepth)*20, y: CGFloat(line.lineNumber)*codeLineHeight))
                separatorLine.addLine(to: CGPoint(x: self.frame.width, y: CGFloat(line.lineNumber)*codeLineHeight))
                
            }
            separatorLine.strokePath()
        }
    }
    
}
