//
//  CodeLineBuildPosition.swift
//  Cubeling
//
//  Created by Heiko Etzold on 22.07.20.
//  MIT License
//

import UIKit

class CodeLineBuildPosition: CodeLine {

    override func setNumberOfValues() {
        numberOfValues = 1
    }
    override func setCodeLineContent() {
        listOfStrings[0] = NSMutableAttributedString(string: "\(NSLocalizedString("CodeAddCube",comment:"buildCube"))(\(NSLocalizedString("CodeAddCubeAt",comment:"at")): ")
        listOfStrings[1] = NSMutableAttributedString(string: ")")
        
        listOfValues[0].removeFromSuperview()
        listOfValues[0] = StringValueBox(codeLine: self, initValue: Int(0))
        self.addSubview(listOfValues[0])
        
    }

}
