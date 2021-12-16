//
//  CodeLineSetPosition.swift
//  Cubeling
//
//  Created by Heiko Etzold on 22.07.20.
//  MIT License
//

import UIKit

class CodeLineSetPosition: CodeLine {

     override func setNumberOfValues() {
           numberOfValues = 3
       }
       override func setCodeLineContent() {
           listOfStrings[0] = NSMutableAttributedString(string: "")
           listOfStrings[1] = NSMutableAttributedString(string: " = ( ")
           listOfStrings[2] = NSMutableAttributedString(string: " , ")
           listOfStrings[3] = NSMutableAttributedString(string: " )")
           
           listOfValues[0].removeFromSuperview()
           listOfValues[0] = StringValueBox(codeLine: self, initValue: Int(0))
           self.addSubview(listOfValues[0])

           listOfValues[1].setColors(shownColor: xAxisColor, editColor: xAxisColor)
           listOfValues[2].setColors(shownColor: yAxisColor, editColor: yAxisColor)
       }


}
