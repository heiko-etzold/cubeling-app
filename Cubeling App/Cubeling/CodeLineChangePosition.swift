//
//  CodeLineChangePosition.swift
//  Cubeling
//
//  Created by Heiko Etzold on 22.07.20.
//  MIT License
//

import UIKit

class CodeLineChangePosition: CodeLine {

    override func setNumberOfValues() {
        numberOfValues = 3
    }
    override func setCodeLineContent() {
        listOfStrings[0] = NSMutableAttributedString(string: "\(NSLocalizedString("CodeChangePosition",comment:"change"))(")
        listOfStrings[1] = NSMutableAttributedString(string: ", \(NSLocalizedString("CodeChangePositionBy",comment:"by")): ( ")
        listOfStrings[2] = NSMutableAttributedString(string: " , ")
        listOfStrings[3] = NSMutableAttributedString(string: " ))")

        listOfValues[0].removeFromSuperview()
        listOfValues[0] = StringValueBox(codeLine: self, initValue: Int(0))
        self.addSubview(listOfValues[0])

        
        listOfValues[1].setColors(shownColor: xAxisColor, editColor: xAxisColor)
        listOfValues[2].setColors(shownColor: yAxisColor, editColor: yAxisColor)
    }

}
