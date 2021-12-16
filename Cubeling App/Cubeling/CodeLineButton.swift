//
//  PreviewCodeLine.swift
//  Cubeling
//
//  Created by Heiko Etzold on 25.07.20.
//  MIT License
//

import UIKit

class CodeLineButton: UIButton {
    
    var currentCodeLineType : CodeLineTypes!
    var isVisible = Bool(true)

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
            labelText = "\(NSLocalizedString("CodeLoopTextDo", comment: "CodeLoopTextDo")) \(NSLocalizedString("CodeCountingNumberText", comment: "CodeCountingNumberText")) \(NSLocalizedString("CodeLoopTextTimes", comment: "CodeLoopTextTimes")) {…}"
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
        
        if #available(iOS 13.4, *) {
            self.isPointerInteractionEnabled = true
        }
        
        if(lineType == .loopStart){
            let varPos = leftLabelOffset+CGFloat(NSMutableAttributedString(string: "\(NSLocalizedString("CodeLoopTextDo", comment: "CodeLoopTextDo")) ").length)*characterWidth-leftBoxOffset
            let varWidth = CGFloat(NSMutableAttributedString(string: "\(NSLocalizedString("CodeCountingNumberText", comment: "CodeCountingNumberText"))").length)*characterWidth+2*leftBoxOffset
            let variableBackground = UIView(frame: CGRect(x: varPos, y: 5, width: varWidth, height: self.frame.height-10))
            variableBackground.isUserInteractionEnabled = false
            variableBackground.layer.cornerRadius = cornerRadius
            variableBackground.backgroundColor = .systemRed.withAlphaComponent(0.1)
            self.addSubview(variableBackground)
        }
        
        if(lineType == .setPosition || lineType == .changePosition || lineType == .buildPosition || lineType == .removePosition){
            var varPos = leftLabelOffset-leftBoxOffset
            let varWidth = CGFloat(NSMutableAttributedString(string: "\(NSLocalizedString("CodePositionText", comment: "CodePositionText"))").length)*characterWidth+2*leftBoxOffset
            switch lineType {
            case .changePosition:
                varPos = leftLabelOffset+CGFloat(NSMutableAttributedString(string: "\(NSLocalizedString("CodeChangePosition", comment: "CodeChangePosition"))(").length)*characterWidth-leftBoxOffset
            case .buildPosition:
                varPos = leftLabelOffset+CGFloat(NSMutableAttributedString(string: "\(NSLocalizedString("CodeAddCube", comment: "CodeAddCube"))(\(NSLocalizedString("CodeAddCubeAt", comment: "CodeAddCubeAt")): ").length)*characterWidth-leftBoxOffset
            case .removePosition:
                varPos = leftLabelOffset+CGFloat(NSMutableAttributedString(string: "\(NSLocalizedString("CodeRemoveCube", comment: "CodeRemoveCube"))(\(NSLocalizedString("CodeAddCubeAt", comment: "CodeAddCubeAt")): ").length)*characterWidth-leftBoxOffset
            default:
                break
            }
            
            let variableBackground = UIView(frame: CGRect(x: varPos, y: 5, width: varWidth, height: self.frame.height-10))
            variableBackground.isUserInteractionEnabled = false
            variableBackground.layer.cornerRadius = cornerRadius
            variableBackground.backgroundColor = stringValueColor.withAlphaComponent(0.2)
            self.addSubview(variableBackground)
        }

        
        if(lineType == .buildCoordinates || lineType == .removeCoordinates || lineType == .setPosition || lineType == .changePosition){
            
            var xVarPos = leftLabelOffset+CGFloat(NSMutableAttributedString(string: "\(NSLocalizedString("CodeAddCube", comment: "CodeAddCube"))(\(NSLocalizedString("CodeAddCubeAt", comment: "CodeAddCubeAt")): (").length)*characterWidth-leftBoxOffset
            let varWidth = CGFloat(NSMutableAttributedString(string: "\(NSLocalizedString("CodeNumberText", comment: "CodeNumberText"))").length)*characterWidth+2*leftBoxOffset
            switch lineType {
            case .removeCoordinates:
                xVarPos = leftLabelOffset+CGFloat(NSMutableAttributedString(string: "\(NSLocalizedString("CodeRemoveCube", comment: "CodeRemoveCube"))(\(NSLocalizedString("CodeAddCubeAt", comment: "CodeAddCubeAt")): (").length)*characterWidth-leftBoxOffset
            case .changePosition:
                xVarPos = leftLabelOffset+CGFloat(NSMutableAttributedString(string: "\(NSLocalizedString("CodeChangePosition", comment: "CodeChangePosition"))(\(NSLocalizedString("CodePositionText", comment: "CodePositionText")), \(NSLocalizedString("CodeChangePositionBy", comment: "CodeChangePositionBy")): (").length)*characterWidth-leftBoxOffset
            case .setPosition:
                xVarPos = leftLabelOffset+CGFloat(NSMutableAttributedString(string: "\(NSLocalizedString("CodePositionText", comment: "CodePositionText")) = (").length)*characterWidth-leftBoxOffset
            default:
                break
            }
            
            
            let xVariableBackground = UIView(frame: CGRect(x: xVarPos, y: 5, width: varWidth, height: self.frame.height-10))
            xVariableBackground.isUserInteractionEnabled = false
            xVariableBackground.layer.cornerRadius = cornerRadius
            xVariableBackground.backgroundColor = xAxisColor.withAlphaComponent(0.1)
            self.addSubview(xVariableBackground)
            
            
            let yVarPos = xVarPos + varWidth-2*leftBoxOffset + CGFloat(NSMutableAttributedString(string: ",").length)*characterWidth
            
            let yVariableBackground = UIView(frame: CGRect(x: yVarPos, y: 5, width: varWidth, height: self.frame.height-10))
            yVariableBackground.isUserInteractionEnabled = false
            yVariableBackground.layer.cornerRadius = cornerRadius
            yVariableBackground.backgroundColor = yAxisColor.withAlphaComponent(0.1)
            self.addSubview(yVariableBackground)
        }
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
            alpha = isEnabled ? (isVisible ? 1 : 0) : 0.5
        }
    }
    
    @objc func tapButton(sender: UIButton){
        codeView.addEmptyStructCodeLine(type: currentCodeLineType)
        _ = codeView.addCodeLine(type: currentCodeLineType)
    }
    
}
