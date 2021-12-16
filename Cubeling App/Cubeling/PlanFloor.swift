//
//  PlanFloor.swift
//  Cubeling
//
//  Created by Heiko Etzold on 16.08.20.
//  MIT License
//


import UIKit

class PlanFloor: UIView {

    var x = Int(0)
    var y = Int(0)

    let label = UILabel()
    
    init(x: Int, y: Int) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.x = x
        self.y = y
        
        if((x+y)%2==0){
            self.backgroundColor = lightFloorColor
        }
        else{
            self.backgroundColor = darkFloorColor
        }
        
        
        //add number label
        label.textAlignment=NSTextAlignment.center
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        
        //add recognizers
        let tap = UITapGestureRecognizer(target: self, action: #selector(planTapped))
        self.addGestureRecognizer(tap)

        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(planLongTapped));
        self.addGestureRecognizer(longTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //change number on field
    func updateFieldNumber(){
        if(sceneView.heightNumberByField(x: x, y: y) > 0){
            label.text="\(sceneView.heightNumberByField(x: x, y: y))"
        }
        else{
            label.text = ""
        }
        label.sizeToFit()
    }
    
    
    override func layoutSubviews() {
        label.font = label.font.withSize(self.frame.width/3)
    }
    
    
    
    //add new cube
    @objc func planTapped(sender: UITapGestureRecognizer) {
        if let tappedView = sender.view as? PlanFloor{
            let tappedX = tappedView.x
            let tappedY = tappedView.y

            //only inside grid, for wooden cubes and when code tracing is disabled
            if(tappedX>=1 && tappedX<=numberOfFields && tappedY>=1 && tappedY<=numberOfFields && typeOfCubes==0 && codeIsTracing == false){
                
                //make all cubes visible
                for cubeNode in sceneView.setOfCubesNodes{
                    cubeNode.opacity = 1
                }
                sceneView.cubeOpacity = 1
                sceneView.cubesAreVisible = true
                
                //add cube and code line
                sceneView.addCube(x: tappedX, y: tappedY, z: sceneView.heightNumberByField(x: tappedX, y: tappedY)+1)
                sceneView.addCodeLineWithCreatedCube(x: tappedX, y: tappedY)

            }
        }
    }
    
    
    //remove cube
    @objc func planLongTapped(sender: UILongPressGestureRecognizer) {
        if let tappedView = sender.view as? PlanFloor{
            let tappedX = tappedView.x
            let tappedY = tappedView.y
            
            let height = sceneView.heightNumberByField(x: tappedX, y: tappedY)
            
            //only for wooden cube when code tracing is disabled
            if(typeOfCubes == 0 && sender.state == .began && codeIsTracing == false){
                for removableCube in sceneView.setOfCubesNodes.filter({$0.x == tappedX && $0.y == tappedY && $0.z == height}){
                    sceneView.removeCube(cubeNode: removableCube)
                    sceneView.addCodeLineWithRemovedCube(x: tappedX, y: tappedY)
                }
            }
        }
    }
}
