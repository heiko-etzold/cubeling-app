//
//  StringPickerViewController.swift
//  Cubeling
//
//  Created by Heiko Etzold on 21.07.20.
//  MIT License
//

import UIKit


class StringPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var connectedValueBox : StringValueBox!

    let alphabet = ["","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

    
    override func viewDidLoad() {
        super.viewDidLoad()        
        valuePicker.selectRow(connectedValueBox.value, inComponent: 0, animated: false)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        connectedValueBox.clearValueBox()
    }

    
    
    
    @IBOutlet weak var valuePicker: UIPickerView!
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 27
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        if(row == 0){
            pickerLabel.text = ""
        }
        else{
            pickerLabel.text = "\(NSLocalizedString("CodePositionText", comment: "CodePositionText"))\(alphabet[row])"
        }
        pickerLabel.font = UIFont(name: "Menlo-Regular", size: 17) 
        pickerLabel.textAlignment = .center
        return pickerLabel
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        connectedValueBox.value = row
        connectedValueBox.valueIsSet = (row != 0)
        connectedValueBox.connectedCodeLine.renewCodeLine()
        
        if let infoLabelBox = connectedValueBox as? InfoStringValueBox{
            infoLabelBox.label.text = row==0 ? " " : "\(NSLocalizedString("CodePositionText", comment: "CodePositionText"))\(alphabet[row])"
            infoLabelBox.label.sizeToFit()
            infoLabelBox.label.frame.size.height = codeLineHeight-2*topBoxOffset
            codeView.setInformation()

        }
        else{
            codeView.showAllCubes()

        }
    }
    
    
    
    
   

}


