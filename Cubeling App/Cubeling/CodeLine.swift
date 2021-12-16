//
//  CodeLine.swift
//  Cubeling
//
//  Created by Heiko Etzold on 21.07.20.
//  MIT License
//

import UIKit


class CodeLine: UIView, UIGestureRecognizerDelegate, UIPointerInteractionDelegate {
    
    
    var lineNumber = Int(0)
    var loopDepth = Int(0)
    
    var setOfFixedCodeLines : Set<CodeLine> = []
    var numberOfFixedLinesBelow = Int(0)
    
    
    var contentView = UIView()
    var label = UILabel()
    let handleView = UIView(frame: CGRect(x: 300, y: 0, width: 40, height: codeLineHeight))
    let deleteView = UIView(frame: CGRect(x: 300, y: 0, width: 40, height: codeLineHeight))
    
    var numberOfValues = Int(0)
    
    var listOfStrings : [NSMutableAttributedString] = []
    var listOfValues : [NumberValueBox] = []
    
    var emptyLineNumber = Int(0)
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if(gestureRecognizer is UISwipeGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer){
            return true
        }
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    @available(iOS 13.4, *)
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        var pointerStyle: UIPointerStyle? = nil

        if let interactionView = interaction.view {
            let targetedPreview = UITargetedPreview(view: interactionView)
            pointerStyle = UIPointerStyle(effect: UIPointerEffect.automatic(targetedPreview))
        }
        return pointerStyle
    }


    
    
    init(lineNumber: Int) {
        super.init(frame: .zero)
        
        self.frame.origin = displayPositionByLineNumber(codeView.insertLineNumber, depth: loopDepth)
        self.lineNumber = lineNumber
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panCodeLine))
        panRecognizer.delegate = self
        if #available(iOS 13.4, *) {
            panRecognizer.allowedScrollTypesMask = .continuous
        }
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressCodeLine))
        longPressRecognizer.delegate = self
        longPressRecognizer.minimumPressDuration = 0.25
        
        let leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipeCodeLine))
        leftSwipeRecognizer.direction = .left
        leftSwipeRecognizer.delegate = self
        
       
        
        let rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipeCodeLine))
        rightSwipeRecognizer.direction = .right
        rightSwipeRecognizer.delegate = self
        
        self.addSubview(contentView)
        handleView.addGestureRecognizer(panRecognizer)
        handleView.addGestureRecognizer(longPressRecognizer)
        if #available(iOS 13.4, *) {
            let pointerInteraction = UIPointerInteraction(delegate: self)
            handleView.addInteraction(pointerInteraction)
        }

        self.addGestureRecognizer(leftSwipeRecognizer)
        self.addGestureRecognizer(rightSwipeRecognizer)
        
        setOfFixedCodeLines.insert(self)
        
        self.frame.size.height = codeLineHeight+5
        self.frame.size.width = codeLineWidth
        self.backgroundColor = systemBackgroundColor.withAlphaComponent(0.8)
        
        contentView.backgroundColor = .clear
        contentView.isUserInteractionEnabled = false
        
        setSpecialContent()
        
        
        //Codezeilen-Texlabel
        label.frame = CGRect(x: codeView.widthOfLineNumbers+CGFloat(loopDepth)*20+leftLabelOffset, y: 0, width: codeLineWidth-leftLabelOffset, height: codeLineHeight)
        label.font = UIFont(name: "Menlo", size: characterSize)
        contentView.addSubview(label)
        
        //Erzeuge Text- und Variablenliste
        setNumberOfValues()
        let string = NSMutableAttributedString(string: "")
        for _ in 0 ..< numberOfValues{
            listOfStrings += [string]
            let value = NumberValueBox(codeLine: self, initValue: Int(0))
            listOfValues += [value]
            self.addSubview(value)
        }
        listOfStrings += [string]
        
        
        //Passe entsprechend des Codezeilentyps an
        setCodeLineContent()
        renewCodeLine()
        
        
        
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    
    func setNumberOfValues(){
    }
    
    func setCodeLineContent(){
    }
    
    
    func setSpecialValue(){
        
    }
    
    func changeColorOfLineLabel(){
        
    }
    
    
    func setSpecialContent(){
        
        self.addSubview(handleView)
        handleView.translatesAutoresizingMaskIntoConstraints = false
        handleView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        handleView.heightAnchor.constraint(equalToConstant: codeLineHeight).isActive = true
        handleView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        handleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        for i in -1...1{
            let lineView = UIView(frame: CGRect(x: 10, y: handleView.frame.height/2+CGFloat(i)*5-1, width: 20, height: 2))
            lineView.backgroundColor = opaqueSeparatorColor
            lineView.layer.cornerRadius = 1
            handleView.addSubview(lineView)
        }
        
        self.addSubview(deleteView)
        deleteView.translatesAutoresizingMaskIntoConstraints = false
        deleteView.widthAnchor.constraint(equalTo: handleView.widthAnchor).isActive = true
        deleteView.heightAnchor.constraint(equalTo: handleView.heightAnchor).isActive = true
        deleteView.leftAnchor.constraint(equalTo: handleView.rightAnchor).isActive = true
        deleteView.topAnchor.constraint(equalTo: handleView.topAnchor).isActive = true

        deleteView.backgroundColor = .systemRed
        deleteView.frame.origin.x = codeView.codeLinesView.frame.width//-deleteView.frame.width
        let deleteButton = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        } else {
        }
        deleteButton.addTarget(self, action: #selector(removeCodeLine), for: .touchUpInside)
        deleteButton.tintColor = secondaryBackgroundColor
        deleteButton.sizeToFit()
        deleteButton.center = CGPoint(x: deleteView.frame.width/2, y: deleteView.frame.height/2)
        deleteView.addSubview(deleteButton)
    }
    
    
    override func layoutSubviews() {
        renewShape()
        
    }
    
    
    func renewShape(){
        codeView.codeLinesView.layoutIfNeeded()
        contentView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat(setOfFixedCodeLines.count)*codeLineHeight+5)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path().cgPath
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = contentView.bounds
        maskLayer.path = path().cgPath
        contentView.layer.mask = maskLayer
        
        
        for line in setOfFixedCodeLines.sorted(by: {$0.lineNumber < $1.lineNumber}){
            line.superview?.bringSubviewToFront(line)
        }
    }
    func renewCodeLine(){
        //Text
        let text = NSMutableAttributedString()
        
        for i in 0 ..< listOfStrings.count-1{
            //Text bis zur i-ten Valuebox
            text.append(listOfStrings[i])
            
            //passe Valuebox an
            listOfValues[i].renewPosition(textBeforeBox: text)
            
            //Inhalt der i-ten Valuebox
            if(listOfValues[i].value == 0){
                if(listOfValues[i].isActive){
                    switch (listOfValues[i].signumIsMinus,listOfValues[i].valueIsSet){
                    case (false,false):
                        text.append(NSMutableAttributedString(string: " "))
                    case (true,false):
                        text.append(NSMutableAttributedString(string: "-"))
                    default:
                        text.append(NSMutableAttributedString(string: "0"))
                    }
                }
                else{
                    if(listOfValues[i].valueIsSet){
                        text.append(NSMutableAttributedString(string: "0"))
                    }
                    else{
                        text.append(NSMutableAttributedString(string: "?"))
                    }
                    
                }
            }
            else{
                if(listOfValues[i] is StringValueBox){
                    text.append(NSMutableAttributedString(string: "\(NSLocalizedString("CodePositionText",comment:"position"))\(alphabet[listOfValues[i].value])"))
                }
                else{
                    text.append(NSMutableAttributedString(string: "\(listOfValues[i].value)"))
                }
            }
        }
        //restlicher Text
        text.append(listOfStrings.last!)
        label.attributedText = text
        
        changeColorOfLineLabel()
        
        
        

        
        renewShape()
        label.frame.origin.x = codeView.widthOfLineNumbers+CGFloat(loopDepth)*20+leftLabelOffset
        
    }
    
    
    
    var topConstraint = NSLayoutConstraint()
    
    
    
    
    func path() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width, y: CGFloat(setOfFixedCodeLines.count)*codeLineHeight))
        path.addLine(to: CGPoint(x: 0, y: CGFloat(setOfFixedCodeLines.count)*codeLineHeight))
        path.close()
        
        return path
    }
    
    
    func insertShadow(){
        
        
        UIView.animate(withDuration: 0.2, animations: {
            for line in setOfCodeLines{
                line.hideDeleteButton()
            }
        })
        
        
        removeShadow()
        codeView.insertCodeLineNumberIndicator.alpha = 0
        
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = path().cgPath
        shadowLayer.frame = contentView.bounds
        
        shadowLayer.shadowOpacity = 0.8
        shadowLayer.shadowRadius = 8
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
        
        let maskLayer = CAShapeLayer()
        let bigPath = UIBezierPath(rect: CGRect(x: -20, y: -20, width: contentView.frame.width+40, height: contentView.frame.height+40))
        bigPath.append(path())
        maskLayer.path = bigPath.cgPath
        maskLayer.fillRule = .evenOdd
        shadowLayer.mask = maskLayer
        
        self.layer.insertSublayer(shadowLayer, at: 0)
        
    }
    
    func removeShadow(){
        if let subLayers = self.layer.sublayers?.filter({$0 is CAShapeLayer}){
            for subLayer in subLayers{
                subLayer.removeFromSuperlayer()
            }
        }
        codeView.insertCodeLineNumberIndicator.alpha = 1
    }
    
    @objc func longPressCodeLine(sender: UILongPressGestureRecognizer){
        if(sender.state == .began){
            var exeptLineNumbers : [Int] = []
            for line in setOfFixedCodeLines.sorted(by: {$0.lineNumber < $1.lineNumber}){
                line.superview?.bringSubviewToFront(line)
                exeptLineNumbers.append(line.lineNumber)
            }
            exeptLineNumbers.removeLast()
            insertShadow()
        }
        if(sender.state == .ended){
            
            removeShadow()
            codeView.strokesBetweenCodeLinesView.clearLines()
        }
        
        
        
        
    }
    
    
    @objc func panCodeLine(sender: UIPanGestureRecognizer){
        
        //save lines that must not be moved
        if(sender.state == .began){
            var exceptLineNumbers : [Int] = []
            for line in setOfFixedCodeLines.sorted(by: {$0.lineNumber < $1.lineNumber}){
                line.superview?.bringSubviewToFront(line)
                exceptLineNumbers.append(line.lineNumber)
            }
            exceptLineNumbers.removeLast()
            
            insertShadow()
         
            emptyLineNumber = lineNumber
        }
        
        //move current line and connected fixed lines
        for line in setOfFixedCodeLines.sorted(by: {$0.lineNumber < $1.lineNumber}){
            if(sender.state == .began){
                line.superview?.bringSubviewToFront(line)
            }
            line.frame.origin.y += sender.translation(in: self).y

            
            if(codeView.scrollView.contentSize.height > codeView.scrollView.frame.height){
                codeView.scrollView.contentOffset.y += sender.translation(in: self).y

            }

        }
        
        //rearrange line when it is upper than first line
        if(self.frame.origin.y < -codeLineHeight/2){
            var i = 0
            for line in setOfFixedCodeLines.sorted(by: {$0.lineNumber < $1.lineNumber}){
                line.frame.origin.y = -codeLineHeight/2+CGFloat(i)*codeLineHeight
                i+=1
            }
        }
        
        //rearrange line when it is downer than last line
        if(setOfFixedCodeLines.sorted(by: {$0.lineNumber < $1.lineNumber}).last!.frame.origin.y > CGFloat(setOfCodeLines.count-1)*codeLineHeight+codeLineHeight/2){
            var i = -1
            for line in setOfFixedCodeLines.sorted(by: {$0.lineNumber > $1.lineNumber}){
                line.frame.origin.y = codeLineHeight/2+CGFloat(setOfCodeLines.count+i)*codeLineHeight
                i-=1
            }
            
        }
        
        
        //when line is moving up
        if(sender.translation(in: self).y < 0){
            //reduce line number of up moved lines, when half of upper line is reached (with condition not to be smaller than line 1)
            if(lineNumberByDisplayPosition(self.frame.origin.y-codeLineHeight/2) <= lineNumber && lineNumberByDisplayPosition(self.frame.origin.y-codeLineHeight/2)>=1){
                if(!(self is CodeLineLoopStart && self.lineNumber == 1)){
                    for line in setOfFixedCodeLines{
                        line.lineNumber = lineNumberByDisplayPosition(line.frame.origin.y+codeLineHeight/2)
                        line.topConstraint.constant = line.frame.origin.y
                    }
                }
            }
        }
        
        
        //when line is moving down
        if(sender.translation(in: self).y > 0){
            //when line is moves down more than a half line height (with condition not to be downer then last line)
            if(lineNumberByDisplayPosition(self.frame.origin.y+codeLineHeight/2) >= lineNumber && lineNumberByDisplayPosition(self.frame.origin.y+codeLineHeight/2)+numberOfFixedLinesBelow <= setOfCodeLines.sorted(by: {$0.lineNumber < $1.lineNumber}).last!.lineNumber){
                //enlarge line number for current line and connected fixed lines
                for line in setOfFixedCodeLines{
                    line.lineNumber = lineNumberByDisplayPosition(line.frame.origin.y+codeLineHeight/2)
                }
                //recalc loop depths
                for line in setOfFixedCodeLines{
                    line.loopDepth = setOfCodeLines.filter({$0.lineNumber < line.lineNumber && $0 is CodeLineLoopStart}).count-setOfCodeLines.filter({$0.lineNumber <= line.lineNumber && $0 is CodeLineLoopEnd}).count
                    line.topConstraint.constant = line.frame.origin.y
                }
            }
        }
        
        
        //when line was moved up, change other lines
        if(emptyLineNumber > lineNumber){
            for line in setOfCodeLines.filter({!setOfFixedCodeLines.contains($0) && lineNumber <= $0.lineNumber && $0.lineNumber < emptyLineNumber}).sorted(by: {$0.lineNumber > $1.lineNumber}){
                line.lineNumber += 1+numberOfFixedLinesBelow
                //                    line.label.text = "\(line.lineNumber)"
                emptyLineNumber -= 1
                var exeptLineNumbers : [Int] = []
                for fixedLine in self.setOfFixedCodeLines.sorted(by: {$0.lineNumber < $1.lineNumber}){
                    exeptLineNumbers.append(fixedLine.lineNumber)
                }
                line.topConstraint.constant = displayPositionByLineNumber(line.lineNumber, depth: line.loopDepth).y
                UIView.animate(withDuration: 0.2, animations: {
                    codeView.codeLinesView.layoutIfNeeded()
                    //das lässt die aktuelle Zeile irgendwie zuckeln
                }, completion: {(_: Bool) in
                    var exeptLineNumbers : [Int] = []
                    for fixedLine in self.setOfFixedCodeLines.sorted(by: {$0.lineNumber < $1.lineNumber}){
                        exeptLineNumbers.append(fixedLine.lineNumber)
                    }
                    exeptLineNumbers.removeLast()
                })
                for anyLine in setOfCodeLines{
                    anyLine.loopDepth = setOfCodeLines.filter({$0.lineNumber < anyLine.lineNumber && $0 is CodeLineLoopStart}).count-setOfCodeLines.filter({$0.lineNumber <= anyLine.lineNumber && $0 is CodeLineLoopEnd}).count
                }
                for fixedLine in setOfFixedCodeLines{
                    fixedLine.renewCodeLine()
                }
                self.insertShadow()
                
            }
            
        }
        
        
        //when line finally was moved down, change other lines
        if(emptyLineNumber < lineNumber){
            //look for lines previously lying directly under current line (or connected fixed lines)
            for line in setOfCodeLines.filter({!setOfFixedCodeLines.contains($0)}).sorted(by: {$0.lineNumber < $1.lineNumber}).filter({lineNumber+numberOfFixedLinesBelow >= $0.lineNumber && $0.lineNumber > emptyLineNumber+numberOfFixedLinesBelow }){
                    //move other line up
                    line.lineNumber -= 1+numberOfFixedLinesBelow
                    emptyLineNumber += 1
                    var exceptLineNumbers : [Int] = []
                    for fixedLine in self.setOfFixedCodeLines.sorted(by: {$0.lineNumber < $1.lineNumber}){
                        exceptLineNumbers.append(fixedLine.lineNumber)
                    }
                    exceptLineNumbers.removeLast()
                    exceptLineNumbers.append(lineNumber-1)
                    
                    line.topConstraint.constant = displayPositionByLineNumber(line.lineNumber, depth: line.loopDepth).y
                    UIView.animate(withDuration: 0.2, animations: {
                        codeView.codeLinesView.layoutIfNeeded()
                    }, completion: {(_: Bool) in
                        var exceptLineNumbers : [Int] = []
                        for fixedLine in self.setOfFixedCodeLines.sorted(by: {$0.lineNumber < $1.lineNumber}){
                            exceptLineNumbers.append(fixedLine.lineNumber)
                        }
                        exceptLineNumbers.removeLast()
                    })
                    for anyLine in setOfCodeLines{
                        anyLine.loopDepth = setOfCodeLines.filter({$0.lineNumber < anyLine.lineNumber && $0 is CodeLineLoopStart}).count-setOfCodeLines.filter({$0.lineNumber <= anyLine.lineNumber && $0 is CodeLineLoopEnd}).count
                    }
                    for fixedLine in self.setOfFixedCodeLines{
                        fixedLine.renewCodeLine()
                    }
                    self.insertShadow()
            }
        }
        
        
        //set moved line to final position
        if(sender.state == .ended){
            for line in setOfCodeLines.filter({$0 is CodeLineLoopStart}).sorted(by: {$0.lineNumber < $1.lineNumber}){
                line.numberOfFixedLinesBelow = (line as! CodeLineLoopStart).connectedEndLine.lineNumber-line.lineNumber
                
                for otherLine in setOfCodeLines{
                    if(line.lineNumber <= otherLine.lineNumber && otherLine.lineNumber <= (line as! CodeLineLoopStart).connectedEndLine.lineNumber){
                        line.setOfFixedCodeLines.insert(otherLine)
                    }
                    else{
                        line.setOfFixedCodeLines.remove(otherLine)
                    }
                }
                line.topConstraint.constant = displayPositionByLineNumber(line.lineNumber, depth: line.loopDepth).y
                codeView.codeLinesView.layoutIfNeeded()
                line.renewCodeLine()
            }
            
            for line in setOfFixedCodeLines{
                line.topConstraint.constant = displayPositionByLineNumber(line.lineNumber, depth: line.loopDepth).y
                UIView.animate(withDuration: 0.1, animations: {
                    codeView.codeLinesView.layoutIfNeeded()
                }, completion: {(_: Bool) in
                    self.removeShadow()
                    
                    line.renewCodeLine()
                })
            }
            codeView.showAllCubes()
            
            
            
        }
        
        //reset translation
        sender.setTranslation(.zero, in: self)
        
        
    }
    
    
    
    @objc func leftSwipeCodeLine(sender: UISwipeGestureRecognizer){
        for line in setOfCodeLines{
            line.hideDeleteButton()
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.deleteView.frame.origin.x = codeView.codeLinesView.frame.width-self.deleteView.frame.width
            self.backgroundColor = secondaryBackgroundColor
            if(self is CodeLineLoopStart){
                for line in self.setOfFixedCodeLines{
                    line.backgroundColor = secondaryBackgroundColor
                }
            }
        })
        
    }
    @objc func rightSwipeCodeLine(sender: UISwipeGestureRecognizer){
        hideDeleteButton()
    }
    
    func hideDeleteButton(){
        UIView.animate(withDuration: 0.2, animations: {
            self.deleteView.frame.origin.x = codeView.codeLinesView.frame.width
            self.backgroundColor = systemBackgroundColor.withAlphaComponent(0.8)
            if(self is CodeLineLoopStart){
                for line in self.setOfFixedCodeLines{
                    if(line.deleteView.frame.origin.x == codeView.codeLinesView.frame.width){
                        line.backgroundColor = systemBackgroundColor.withAlphaComponent(0.8)
                    }
                }
            }
        })
    }
    
    @objc func removeCodeLine(sender: UIButton){
        
        for fixedLine in self.setOfFixedCodeLines{
            setOfCodeLines.remove(fixedLine)
            fixedLine.removeFromSuperview()
        }
        for line in setOfCodeLines{
            for fixedLine in self.setOfFixedCodeLines{
                line.setOfFixedCodeLines.remove(fixedLine)
            }
        }
        
        codeView.updateLineNumbers()
        
        for line in setOfCodeLines.filter({$0.lineNumber > self.lineNumber}){
            line.lineNumber -= self.setOfFixedCodeLines.count
            line.topConstraint.constant = displayPositionByLineNumber(line.lineNumber, depth: line.loopDepth).y
            UIView.animate(withDuration: 0.2, animations: {
                codeView.codeLinesView.layoutIfNeeded()
            })
        }

        if(codeView.insertLineNumber > self.lineNumber+self.setOfFixedCodeLines.count){
            codeView.insertLineNumber -= self.setOfFixedCodeLines.count
            UIView.animate(withDuration: 0.2, animations: {
                codeView.insertCodeLineNumberIndicator.center.y = displayPositionByLineNumber(codeView.insertLineNumber, depth: 0).y
                if(codeView.insertLineNumber == 1){
                    codeView.insertCodeLineNumberIndicator.center.y = displayPositionByLineNumber(codeView.insertLineNumber, depth: 0).y+5
                }
            })
        }
        else if(codeView.insertLineNumber > self.lineNumber){
            codeView.insertLineNumber = self.lineNumber
            UIView.animate(withDuration: 0.2, animations: {
                codeView.insertCodeLineNumberIndicator.center.y = displayPositionByLineNumber(codeView.insertLineNumber, depth: 0).y
                if(codeView.insertLineNumber == 1){
                    codeView.insertCodeLineNumberIndicator.center.y = displayPositionByLineNumber(codeView.insertLineNumber, depth: 0).y+5
                }
            })
        }
        
        codeView.renewTextViewContentHeight()
        codeView.showAllCubes()
    }
    
    
}

