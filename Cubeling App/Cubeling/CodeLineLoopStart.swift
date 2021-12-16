//
//  CodeLineLoopStart.swift
//  Cubeling
//
//  Created by Heiko Etzold on 21.07.20.
//  MIT License
//

import UIKit

class CodeLineLoopStart: CodeLine {

    var connectedEndLine : CodeLineLoopEnd!
    
    var currentTracingStep = Int(0)
    

    
    override func setNumberOfValues() {
        numberOfValues = 1
    }

    override func setCodeLineContent() {
        numberOfFixedLinesBelow = 1

        listOfStrings[0] = NSMutableAttributedString(string: "\(NSLocalizedString("CodeLoopTextDo",comment:"do"))  ")
        listOfStrings[1] = NSMutableAttributedString(string: "  \(NSLocalizedString("CodeLoopTextTimes",comment:"times")){")

        listOfValues[0].setColors(shownColor: .systemGray, editColor: .systemGray)
    }

    override func changeColorOfLineLabel() {
        label.textColor = .systemRed

        listOfStrings[0].setColorForText(textForAttribute: "\(NSLocalizedString("CodeLoopTextDo",comment:"do")) ", withColor: .systemRed)
        listOfStrings[1].setColorForText(textForAttribute: " \(NSLocalizedString("CodeLoopTextTimes",comment:"times")){", withColor: .systemRed)
        listOfValues[0].setColors(shownColor: listOfValues[0].boxColor, editColor: .systemRed)
    }

}
