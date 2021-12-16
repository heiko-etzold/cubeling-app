//
//  PreviewCodeLine.swift
//  Cubeling
//
//  Created by Heiko Etzold on 25.07.20.
//  Copyright © 2020 Heiko Etzold. All rights reserved.
//

import UIKit

class CodeLineButton: UIButton {
    
    var currentCodeLineType : CodeLineTypes!

    init(lineType: CodeLineTypes) {
        super.init(frame: .zero)

        currentCodeLineType = lineType
        
        self.addTarget(self, action: #selector(tapButton), for: .touchUpInside)


        var labelText = ""
        
        switch lineType {
        case .buildCoordinates:
            labelText = "\(NSLocalizedString("CodeAddCube", comment: "CodeAddCube"))(\(NSLocalizedString("CodeAddCubeAt", comment: "CodeAddCubeAt")): (\(NSLocalizedString("CodeNumberText", comment: "CodeNumberText")),\(NSLocalizedString("CodeNumberText", comment: "CodeNumberText"))))"
        case .buildPosition:
            labelText = "\(NSLocalizedString("CodeAddCube", comment: "CodeAddCube"))(\(NSLocalizedString("CodeAddCubeAt", comment: "CodeAddCubeAt")): \(NSLocalizedString("CodePositionText", comment: "CodePositionText")))"
        case .removeCoordinates:
            labelText = "\(NSLocalizedString("CodeRemoveCube", comment: "CodeRemoveCube"))(\(NSLocalizedString("CodeAddCubeAt", comment: "CodeAddCubeAt")): (\(NSLocalizedString("CodeNumberText", comment: "CodeNumberText")),\(NSLocalizedString("CodeNumberText", comment: "CodeNumberText"))))"
        case .removePosition:
            labelText = "\(NSLocalizedString("CodeRemoveCube", comment: "CodeRemoveCube"))(\(NSLocalizedString("CodeAddCubeAt", comment: "CodeAddCubeAt")): \(NSLocalizedString("CodePositionText", comment: "CodePositionText")))"
        case .setPosition:
            labelText = "\(NSLocalizedString("CodePositionText", comment: "CodePositionText")) = (\(NSLocalizedString("CodeNumberText", comment: "CodeNumberText")),\(NSLocalizedString("CodeNumberText", comment: "CodeNumberText")))"
        case .changePosition:
            labelText = "\(NSLocalizedString("CodeChangePosition", comment: "CodeChangePosition"))(\(NSLocalizedString("CodePositionText", comment: "CodePositionText")), \(NSLocalizedString("CodeChangePositionBy", comment: "CodeChangePositionBy")): (\(NSLocalizedString("CodeNumberText", comment: "CodeNumberText")),\(NSLocalizedString("CodeNumberText", comment: "CodeNumberText"))))"
        case .loopStart:
            labelText = "\(NSLocalizedString("CodeLoopTextDo", comment: "CodeLoopTextDo")) … \(NSLocalizedString("CodeLoopTextTimes", comment: "CodeLoopTextTimes")) {}"
        default:
            break
        }
        
        self.setTitle(labelText, for: .normal)
        self.titleLabel?.font =  UIFont(name: "Menlo", size: characterSize)
        self.setTitleColor(labelColor, for: .normal)
        self.backgroundColor = codeLineBackround
        self.layer.cornerRadius = cornerRadius

        self.sizeToFit()
        self.frame.size.width += 2*leftLabelOffset//+label.frame.width

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? tintColor : codeLineBackround
            setTitleColor(isHighlighted ? codeView.backgroundColor : labelColor, for: .normal)
        }
    }
    
    override var isEnabled: Bool{
        didSet {
            alpha = isEnabled ? 1 : 0.5
        }
    }
    
    @objc func tapButton(sender: UIButton){
        _ = codeView.addCodeLine(type: currentCodeLineType)
    }
    
}
