//
//  InfoViewController.swift
//  Cubeling
//
//  Created by Heiko Etzold on 13.02.21.
//  MIT License
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var clockImageView: UIImageView!
    @IBOutlet weak var handImageView: UIImageView!
    @IBOutlet weak var firstInfoLabel: UILabel!
    @IBOutlet weak var secondInfoLabel: UILabel!
    @IBOutlet weak var anotherHandImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        #if targetEnvironment(macCatalyst)
        firstInfoLabel.text = "FirstInfoLabelMacText".localized()
        secondInfoLabel.text = "SecondInfoLabelMacText".localized()
        handImageView.image = UIImage(systemName: "cursorarrow")
        anotherHandImageView.image = UIImage(systemName: "cursorarrow")

        #else
        firstInfoLabel.text = "FirstInfoLabelText".localized()
        secondInfoLabel.text = "SecondInfoLabelText".localized()
        
        #endif
    }
}
