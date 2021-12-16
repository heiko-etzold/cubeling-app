//
//  CodeLineLoopEnd.swift
//  Cubeling
//
//  Created by Heiko Etzold on 21.07.20.
//  MIT License
//

import UIKit

class CodeLineLoopEnd: CodeLine {

    
    override func setSpecialContent() {
        self.isUserInteractionEnabled = false
    }
    
    
    override func setNumberOfValues() {
        numberOfValues = 0
    }
    override func setCodeLineContent() {
        listOfStrings[0] = NSMutableAttributedString(string: "}")
    }
    
    override func changeColorOfLineLabel() {
        listOfStrings[0].setColorForText(textForAttribute: "}", withColor: .systemRed)
    }
}
