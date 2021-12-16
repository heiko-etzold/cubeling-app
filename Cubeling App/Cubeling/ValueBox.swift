//
//  CodeValueBox.swift
//  Cubeling
//
//  Created by Heiko Etzold on 18.05.17.
//  MIT License
//

import UIKit

let leftBoxOffset = CGFloat(2)
let topBoxOffset = CGFloat(2)


class NumberValueBox: UIView, UIPointerInteractionDelegate {
    
    var connectedCodeLine: CodeLine!
    var value = Int(0)
    
    var isActive = Bool(false)
    
    var boxColor = UIColor.gray
    var boxEditColor = UIColor.gray
    let boxBorderWidth = CGFloat(2)
    
    var signumIsMinus = Bool(false)
    var valueIsSet = Bool(false)
    
    let cursor = UIView()
    var curserRightConstraint = NSLayoutConstraint()
    let cursorAnimation = CABasicAnimation(keyPath: "opacity")
    
    init(codeLine: CodeLine, initValue: Int) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        value = initValue
        connectedCodeLine = codeLine

        self.layer.cornerRadius = cornerRadius
        boxColor = labelColor
        boxEditColor = labelColor

        setColors(shownColor: boxColor, editColor: boxEditColor)

        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(openStepper))
        tapGesture.minimumPressDuration = 0
        self.addGestureRecognizer(tapGesture)
        
        
        if #available(iOS 13.4, *) {
            self.addInteraction(UIPointerInteraction(delegate: self))
        }
        
        cursor.backgroundColor = labelColor
        cursor.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(cursor)
        cursor.heightAnchor.constraint(equalToConstant: characterSize).isActive = true
        cursor.widthAnchor.constraint(equalToConstant: 1.4).isActive = true
        cursor.layer.cornerRadius = 0.7
        curserRightConstraint = NSLayoutConstraint(item: cursor, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -characterWidth)
        curserRightConstraint.isActive = true
        cursor.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        cursor.alpha = 0
        
        cursorAnimation.fromValue = 0
        cursorAnimation.toValue = 1
        cursorAnimation.duration = 0.5
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(iOS 13.4, *)
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        var pointerStyle: UIPointerStyle? = nil

        if let interactionView = interaction.view {
            let targetedPreview = UITargetedPreview(view: interactionView)
            pointerStyle = UIPointerStyle(effect: UIPointerEffect.lift(targetedPreview))
        }
        return pointerStyle
    }
    
    
    func setColors(shownColor: UIColor, editColor: UIColor){
        boxColor = shownColor
        boxEditColor = editColor
        
        self.backgroundColor = boxColor.withAlphaComponent(0.2)
        self.layer.borderColor = boxEditColor.cgColor
    }
    
    func renewPosition(textBeforeBox: NSMutableAttributedString){
        self.frame = CGRect(x: codeView.widthOfLineNumbers+leftLabelOffset+CGFloat(connectedCodeLine.loopDepth)*20+CGFloat(textBeforeBox.length-1)*characterWidth-leftBoxOffset, y: topBoxOffset, width: CGFloat(" \(value) ".count)*characterWidth+2*leftBoxOffset , height: codeLineHeight-2*topBoxOffset)
    }
    
    
    
    //Sichtbarmachen des Steppers, wenn Box gedrückt wird
    @objc func openStepper(sender: UILongPressGestureRecognizer){
        if(sender.state == .began){
            activateValueBox()
        }
    }
 
    var identifierForViewController: String{
        return "numberPicker"
    }

    
    func activateCursor(){
        UIView.animate(withDuration: 0.5,
                      delay:0.0,
                      options:[.allowUserInteraction, .curveEaseInOut, .autoreverse, .repeat],
                      animations: { self.cursor.alpha = 1 },
                      completion: nil)
    }
    
    func activateValueBox(){
        
        UIView.animate(withDuration: 0.2, animations: {
            for line in setOfCodeLines{
                line.hideDeleteButton()
            }
        })

        
        activateCursor()
        
        //Box hervorheben
        self.isActive = true
        self.layer.borderWidth = boxBorderWidth
        self.backgroundColor = boxColor.withAlphaComponent(0.05)
        
        //Text anpassen (wichtig, wenn Wert Null ist)
        connectedCodeLine.renewCodeLine()
        if(valueIsSet == false){
            curserRightConstraint.constant = -2*characterWidth
        }
        else{
            curserRightConstraint.constant = -characterWidth
        }
        cursor.layoutIfNeeded()
        
        let storyboard = UIStoryboard(name: "Main~iPad", bundle: nil)

        let vc = storyboard.instantiateViewController(withIdentifier:  identifierForViewController)
        if(identifierForViewController == "numberPicker"){
            (vc as! NumberKeyboardViewController).connectedValueBox = self
        }
        else{
            (vc as! StringPickerViewController).connectedValueBox = self as? StringValueBox
        }
        vc.modalPresentationStyle = .popover
        let pop = vc.popoverPresentationController
        pop?.sourceView = self
        pop?.sourceRect = self.bounds
        pop?.permittedArrowDirections = [.up]
        vc.preferredContentSize = CGSize(width: 170, height: 200)
        parentViewController!.present(vc, animated: true, completion: nil)
    }
    
    
    //Darstellung aufräumen
    func clearValueBox(){
        isActive = false
        connectedCodeLine.renewCodeLine()
        self.layer.borderWidth = 0
        self.backgroundColor = boxColor.withAlphaComponent(0.2)

        if(valueIsSet == false){
            self.signumIsMinus = false
        }

        connectedCodeLine.setSpecialValue()
        cursor.layer.removeAllAnimations()
        cursor.alpha = 0
    }
    
    func setSpecialValue(){
    }

}


let alphabet = ["","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

class StringValueBox: NumberValueBox {
    
    override var identifierForViewController: String{
        return "stringPicker"
    }
    
    override func renewPosition(textBeforeBox: NSMutableAttributedString){
        if(value == 0){
            self.frame = CGRect(x: codeView.widthOfLineNumbers+leftLabelOffset+CGFloat(connectedCodeLine.loopDepth)*20+CGFloat(textBeforeBox.length)*characterWidth-leftBoxOffset, y: topBoxOffset, width: CGFloat(" ".count)*characterWidth+2*leftBoxOffset , height: codeLineHeight-2*topBoxOffset)
        }
        else{
            self.frame = CGRect(x: codeView.widthOfLineNumbers+leftLabelOffset+CGFloat(connectedCodeLine.loopDepth)*20+CGFloat(textBeforeBox.length)*characterWidth-leftBoxOffset, y: topBoxOffset, width: CGFloat("\(NSLocalizedString("CodePositionText",comment:"position"))\(alphabet[value])".count)*characterWidth+2*leftBoxOffset , height: codeLineHeight-2*topBoxOffset)
        }
    }
    
    override func activateCursor() {
    }
}



class InfoStringValueBox: StringValueBox {
    
    let label = UILabel()
    
    override func renewPosition(textBeforeBox: NSMutableAttributedString){
        
        label.text = " "
        label.font = UIFont(name: "Menlo", size: characterSize)
        self.addSubview(label)

        label.sizeToFit()
        label.frame.size.height = codeLineHeight-2*topBoxOffset
        label.frame.origin.x = leftBoxOffset
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalTo: label.widthAnchor, constant: 2*leftBoxOffset).isActive = true
        self.heightAnchor.constraint(equalToConstant: codeLineHeight-2*topBoxOffset).isActive = true

    }
    
    override func clearValueBox(){
        isActive = false
        self.layer.borderWidth = 0
        self.backgroundColor = boxColor.withAlphaComponent(0.2)


        connectedCodeLine.setSpecialValue()
    }
    
}
