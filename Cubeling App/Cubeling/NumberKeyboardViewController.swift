//
//  NumberKeyboardViewController.swift
//  Cubeling
//
//  Created by Heiko Etzold on 21.07.20.
//  MIT License
//

import UIKit



class NumberKeyboardViewController: UIViewController {

    
    var connectedValueBox : NumberValueBox!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.tintColor = connectedValueBox.boxEditColor
        reactivateStepper()
        stepper.value = Double(connectedValueBox.value)


        if #available(iOS 13.0, *) {
            stepper.setDecrementImage(UIImage(systemName: "chevron.down"), for: .normal)
            stepper.setIncrementImage(UIImage(systemName: "chevron.up"), for: .normal)
        } else {
        }
        renewEnabilityOfButtons()

        stepper.tintColor = connectedValueBox.boxEditColor

        for numberButton in [numberButton0,numberButton1,numberButton2,numberButton3,numberButton4,numberButton5,numberButton6,numberButton7,numberButton8,numberButton9,backspaceButton,minusButton]{
            numberButton?.layer.cornerRadius = stepper.subviews.first!.layer.cornerRadius
        }
    

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        connectedValueBox.clearValueBox()
    }

    
    
    
    @IBOutlet weak var numberButton1: UIButton!
    @IBOutlet weak var numberButton2: UIButton!
    @IBOutlet weak var numberButton3: UIButton!
    @IBOutlet weak var numberButton4: UIButton!
    @IBOutlet weak var numberButton5: UIButton!
    @IBOutlet weak var numberButton6: UIButton!
    @IBOutlet weak var numberButton7: UIButton!
    @IBOutlet weak var numberButton8: UIButton!
    @IBOutlet weak var numberButton9: UIButton!
    @IBOutlet weak var numberButton0: UIButton!

    @IBAction func pressNumberButton(_ sender: UIButton) {
        
        if(connectedValueBox.value > 0){
            connectedValueBox.value = 10*connectedValueBox.value + sender.tag
        }
        if(connectedValueBox.value < 0){
            connectedValueBox.value = 10*connectedValueBox.value - sender.tag
        }
        if(connectedValueBox.value == 0){
            if(connectedValueBox.signumIsMinus == false){
                connectedValueBox.value = sender.tag
            }
            else{
                connectedValueBox.value = -sender.tag
                if(sender.tag == 0){
                    connectedValueBox.signumIsMinus = false
                }
            }
        }
        
        connectedValueBox.valueIsSet = true
        connectedValueBox.curserRightConstraint.constant = -characterWidth
        connectedValueBox.cursor.layoutIfNeeded()

        reactivateStepper()
        stepper.value = Double(connectedValueBox.value)
        connectedValueBox.connectedCodeLine.renewCodeLine()
        renewEnabilityOfButtons()
        codeView.showAllCubes()

    }
    
    
    func reactivateStepper(){
        if(connectedValueBox.valueIsSet == false){
            if(connectedValueBox.connectedCodeLine is CodeLineLoopStart){
                stepper.minimumValue = 0
            }
            else{
                stepper.minimumValue = -1
            }
            stepper.maximumValue = 1
        }
        else{
            if(connectedValueBox.connectedCodeLine is CodeLineLoopStart){
                stepper.minimumValue = 0
                stepper.maximumValue = Double(connectedValueBox.value)+1
            }
            else{
                if(connectedValueBox.value >= 0){
                    stepper.maximumValue = Double(connectedValueBox.value)+1
                    stepper.minimumValue = -Double(connectedValueBox.value)-1
                }
                else{
                    stepper.maximumValue = -Double(connectedValueBox.value)+1
                    stepper.minimumValue = Double(connectedValueBox.value)-1
                }
            }
        }
    }
    
    
    @IBOutlet weak var minusButton: UIButton!
    @IBAction func pressMinusButton(_ sender: UIButton) {
        
        if(sender.title(for: .normal)=="–"){
            connectedValueBox.signumIsMinus = true
            renewEnabilityOfButtons()
            connectedValueBox.connectedCodeLine.renewCodeLine()
            renewEnabilityOfButtons()
            codeView.showAllCubes()
            connectedValueBox.curserRightConstraint.constant = -characterWidth
            connectedValueBox.cursor.layoutIfNeeded()
        }
        else{
            connectedValueBox.value = -connectedValueBox.value

            if(connectedValueBox.value >= 0){
                stepper.maximumValue = Double(connectedValueBox.value)+1
                stepper.minimumValue = -Double(connectedValueBox.value)-1
                if(connectedValueBox.value > 0){
                    connectedValueBox.signumIsMinus = false
                }
            }
            else{
                stepper.maximumValue = -Double(connectedValueBox.value)+1
                stepper.minimumValue = Double(connectedValueBox.value)-1
                connectedValueBox.signumIsMinus = true

            }

            stepper.value = Double(connectedValueBox.value)
            connectedValueBox.connectedCodeLine.renewCodeLine()
            renewEnabilityOfButtons()
            codeView.showAllCubes()
        }
    }
    
    
    
    
    @IBOutlet weak var backspaceButton: UIButton!
    
    @IBAction func pressBackspaceButton(_ sender: UIButton) {
        
        if(connectedValueBox.value == 0){
            if(connectedValueBox.signumIsMinus == true){
                connectedValueBox.signumIsMinus = false
            }
            else{
            }
            connectedValueBox.curserRightConstraint.constant = -2*characterWidth

            connectedValueBox.cursor.layoutIfNeeded()
        }
        if(connectedValueBox.value > 0){
            connectedValueBox.value = (connectedValueBox.value - connectedValueBox.value%10)/10
        }
        if(connectedValueBox.value < 0){
            connectedValueBox.value = (connectedValueBox.value - (connectedValueBox.value%10))/10
        }
        
        if(connectedValueBox.value == 0){
            if(connectedValueBox.signumIsMinus == true){
                connectedValueBox.curserRightConstraint.constant = -characterWidth
            }
            else{
                connectedValueBox.curserRightConstraint.constant = -2*characterWidth
            }
            connectedValueBox.cursor.layoutIfNeeded()
            connectedValueBox.valueIsSet = false
            stepper.minimumValue = 0
        }
        
        stepper.value = Double(connectedValueBox.value)
        reactivateStepper()
        connectedValueBox.connectedCodeLine.renewCodeLine()

    
        renewEnabilityOfButtons()

        codeView.showAllCubes()

    }
    
    @IBOutlet weak var stepper: UIStepper!
    @IBAction func pressStepper(_ sender: UIStepper) {
        connectedValueBox.value = Int(sender.value)
        connectedValueBox.valueIsSet = true
        connectedValueBox.connectedCodeLine.renewCodeLine()
        
        connectedValueBox.curserRightConstraint.constant = -characterWidth
        connectedValueBox.cursor.layoutIfNeeded()

        reactivateStepper()
        
        connectedValueBox.connectedCodeLine.setSpecialValue()
        renewEnabilityOfButtons()
        codeView.showAllCubes()
    }
    
    
    func renewEnabilityOfButtons(){
        
        minusButton.isEnabled = false
        if(connectedValueBox.value != 0 && (connectedValueBox.connectedCodeLine is CodeLineLoopStart) == false){
            minusButton.isEnabled = true
            minusButton.setTitle("", for: .normal)
            if #available(iOS 13.0, *) {
                minusButton.setImage(UIImage(systemName: "plusminus"), for: .normal)
            } else {
                minusButton.setTitle("±", for: .normal)
            }
        }

        numberButton0.isEnabled = (connectedValueBox.value == 0 && connectedValueBox.valueIsSet) ? false : true

        if(connectedValueBox.value == 0 && connectedValueBox.valueIsSet == false && connectedValueBox.signumIsMinus == false && (connectedValueBox.connectedCodeLine is CodeLineLoopStart) == false){
            minusButton.isEnabled = true
            minusButton.setImage(UIImage(), for: .normal)
            minusButton.setTitle("–", for: .normal)
        }
        
    }
    
    
}
