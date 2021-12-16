//
//  CodeLineRemoveCoordinates.swift
//  Cubeling
//
//  Created by Heiko Etzold on 22.07.20.
//  MIT License
//

import UIKit

class CodeLineRemoveCoordinates: CodeLine {

    override func setNumberOfValues() {
        numberOfValues = 2
    }
    override func setCodeLineContent() {
        listOfStrings[0] = NSMutableAttributedString(string: "\(NSLocalizedString("CodeRemoveCube",comment:"removeCube"))(\(NSLocalizedString("CodeAddCubeAt",comment:"at")): ( ")
        listOfStrings[1] = NSMutableAttributedString(string: " , ")
        listOfStrings[2] = NSMutableAttributedString(string: " ))")
        
        listOfValues[0].setColors(shownColor: xAxisColor, editColor: xAxisColor)
        listOfValues[1].setColors(shownColor: yAxisColor, editColor: yAxisColor)
    }

}
