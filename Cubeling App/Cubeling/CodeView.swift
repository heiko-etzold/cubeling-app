//
//  CodeView.swift
//  Cubeling
//
//  Created by Heiko Etzold on 18.10.16.
//  MIT License
//

import UIKit





class CodeView: UIView, UIScrollViewDelegate, UIPointerInteractionDelegate {

    
    let scrollViewContainer = UIView()
    let scrollView = UIScrollView()
    let widthOfLineNumbers = CGFloat(30)
    var lineNumbers : [UILabel] = []
    let strokesBetweenCodeLinesView = StrokesBetweenCodeLinesView()
    let codeLinesView = UIView()
    var seperator = UIView()
    var firstHorizontalSeperator = UIView()
    var secondHorizontalSeperator = UIView()
    let codeTracingView = CodeTracingView()


    let keyboardView = UIScrollView()
    var keyboardHeightConstraint = NSLayoutConstraint()

    let traceButton = UIButton(type: .system)
    let nextStepButton = UIButton(type: .system)
    let previousStepButton = UIButton(type: .system)
    var currentCodeStep = Int(-1)
    var listOfStringValues : [[Int]] = []


    let buttonOffset = CGFloat(15)

    let positionInformationView = UIView()
    let positionInformationTextLabel = UILabel(frame: CGRect(x: 0, y: 10, width: 100, height: 30))
    var hiddenBox : InfoStringValueBox!
    let positionInformationDotsLabel = UILabel(frame: CGRect(x: 0, y: 10, width: 100, height: 30))
    let positionInformationValuesLabel = UILabel(frame: CGRect(x: 0, y: 10, width: 100, height: 30))
    
    var insertCodeLineNumberIndicator = UIView()
    var insertLineNumber = Int(1)
    

    var viewsToChangeVisibility : [UIView] = []
    var setOfFixedCodeButtons : Set<CodeLineButton> = []
    var setOfVariableCodeButtons : Set<CodeLineButton> = []
    var setOfLoopCodeButtons : Set<CodeLineButton> = []

    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.backgroundColor = systemBackgroundColor
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @available(iOS 13.4, *)
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        var pointerStyle: UIPointerStyle? = nil

        if let interactionView = interaction.view {
            let targetedPreview = UITargetedPreview(view: interactionView)
            pointerStyle = UIPointerStyle(effect: UIPointerEffect.hover(targetedPreview, preferredTintMode: .none, prefersShadow: true, prefersScaledContent: true))
        }
        return pointerStyle
    }
    
    


    func createContent(){
        
        characterSize = codeLineHeight/7*3
        characterWidth = 0.6*characterSize
        
        
        
        //top offset view (space to touch)
        let topLayout = UIView()
        self.addSubview(topLayout)

        self.addSubview(firstHorizontalSeperator)
        firstHorizontalSeperator.backgroundColor = opaqueSeparatorColor
        
        //container view for scrollable code
        self.addSubview(scrollViewContainer)

        
        //scroll view
        scrollView.showsVerticalScrollIndicator = true
        scrollView.delegate = self
        self.addSubview(scrollView)

        
        //code lines inside scroll view
        scrollView.addSubview(codeLinesView)
        codeLinesView.clipsToBounds = true
        scrollView.addSubview(strokesBetweenCodeLinesView)
        strokesBetweenCodeLinesView.isUserInteractionEnabled = false
        strokesBetweenCodeLinesView.clipsToBounds = true
        
        //line indicator inside scroll view
        let heightOfLineIndicator = CGFloat(20)
        insertCodeLineNumberIndicator.frame = CGRect(x: 0, y: displayPositionByLineNumber(insertLineNumber, depth: 0).y-heightOfLineIndicator/2+5, width: widthOfLineNumbers, height: heightOfLineIndicator)
        insertCodeLineNumberIndicator.backgroundColor = opaqueSeparatorColor
        scrollView.addSubview(insertCodeLineNumberIndicator)
        if #available(iOS 13.4, *) {
            insertCodeLineNumberIndicator.addInteraction(UIPointerInteraction(delegate: self))
        }
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panInsertView))
        insertCodeLineNumberIndicator.addGestureRecognizer(panRecognizer)
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: heightOfLineIndicator/2-1))
        path.addLine(to: CGPoint(x: widthOfLineNumbers-5, y: heightOfLineIndicator/2-1))
        path.addLine(to: CGPoint(x: widthOfLineNumbers-5, y: heightOfLineIndicator/2-2))
        path.addLine(to: CGPoint(x: widthOfLineNumbers, y: heightOfLineIndicator/2))
        path.addLine(to: CGPoint(x: widthOfLineNumbers-5, y: heightOfLineIndicator/2+2))
        path.addLine(to: CGPoint(x: widthOfLineNumbers-5, y: heightOfLineIndicator/2+1))
        path.addLine(to: CGPoint(x: 0, y: heightOfLineIndicator/2+1))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        insertCodeLineNumberIndicator.layer.mask = layer
        
        
        //seperator between code lines and tracking view
        seperator = UIView()
        seperator.backgroundColor = opaqueSeparatorColor
        self.addSubview(seperator)
        
        
        //code trackig view
        codeTracingView.alpha = 1
        scrollView.addSubview(codeTracingView)
        
        
        self.addSubview(secondHorizontalSeperator)
        secondHorizontalSeperator.backgroundColor = opaqueSeparatorColor
        
        
        //bottom offset view (for code tracking)
        let bottomLayout = UIView()
        self.addSubview(bottomLayout)

        
        //position information
        positionInformationTextLabel.font = UIFont(name: positionInformationTextLabel.font.familyName, size: characterSize)
        positionInformationTextLabel.text = NSLocalizedString("InfoPositionTextLabel",comment:"positionInformation")
        bottomLayout.addSubview(positionInformationTextLabel)
        viewsToChangeVisibility.append(positionInformationTextLabel)
        
        hiddenBox = InfoStringValueBox(codeLine: CodeLine(lineNumber: 0), initValue: 0)
        hiddenBox.renewPosition(textBeforeBox: NSMutableAttributedString(string: ""))
        bottomLayout.addSubview(hiddenBox)
        viewsToChangeVisibility.append(hiddenBox)

        positionInformationDotsLabel.font=UIFont(name: positionInformationDotsLabel.font.familyName, size: characterSize)
        positionInformationDotsLabel.text = ": "
        bottomLayout.addSubview(positionInformationDotsLabel)
        viewsToChangeVisibility.append(positionInformationDotsLabel)

        positionInformationValuesLabel.font=UIFont(name: "Menlo", size: characterSize)
        positionInformationValuesLabel.text = ""
        bottomLayout.addSubview(positionInformationValuesLabel)
        viewsToChangeVisibility.append(positionInformationValuesLabel)

        
        //button for start code tracking
        if #available(iOS 13.0, *) {
            traceButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        } else {
            traceButton.setImage(UIImage(named: "playCircle"), for: .normal)
            traceButton.imageEdgeInsets = .init(top: 2, left: 2, bottom: 2, right: 2)
        }
        if #available(iOS 13.4, *) {
            traceButton.isPointerInteractionEnabled = true
        }
        traceButton.addTarget(self, action: #selector(traceCode), for: .touchUpInside)
        bottomLayout.addSubview(traceButton)
        
        
        //button for next code tracing step
        if #available(iOS 13.0, *) {
            nextStepButton.setImage(UIImage(systemName: "chevron.down.circle"), for: .normal)
        } else {
            nextStepButton.setImage(UIImage(named: "downCircle"), for: .normal)
            nextStepButton.imageEdgeInsets = .init(top: 2, left: 2, bottom: 2, right: 2)
        }
        if #available(iOS 13.4, *) {
            nextStepButton.isPointerInteractionEnabled = true
        }
        nextStepButton.addTarget(self, action: #selector(nextStep), for: .touchUpInside)
        self.addSubview(nextStepButton)
        viewsToChangeVisibility.append(nextStepButton)

        
        //button for previous code tracing step
        if #available(iOS 13.0, *) {
            previousStepButton.setImage(UIImage(systemName: "chevron.up.circle"), for: .normal)
        } else {
            previousStepButton.setImage(UIImage(named: "upCircle"), for: .normal)
            previousStepButton.imageEdgeInsets = .init(top: 2, left: 2, bottom: 2, right: 2)
        }
        if #available(iOS 13.4, *) {
            previousStepButton.isPointerInteractionEnabled = true
        }
        previousStepButton.addTarget(self, action: #selector(previousStep), for: .touchUpInside)
        previousStepButton.isEnabled = false
        self.addSubview(previousStepButton)
        viewsToChangeVisibility.append(previousStepButton)


        //keyboard view for code buttons
        self.addSubview(keyboardView)

        for view in viewsToChangeVisibility{
            view.alpha = 0
        }
        
        
        //LAYOUT
        
        topLayout.translatesAutoresizingMaskIntoConstraints = false
        topLayout.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        topLayout.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        topLayout.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        topLayout.heightAnchor.constraint(equalToConstant: 0.5*codeLineHeight).isActive = true

        firstHorizontalSeperator.translatesAutoresizingMaskIntoConstraints = false
        firstHorizontalSeperator.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        firstHorizontalSeperator.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        firstHorizontalSeperator.topAnchor.constraint(equalTo: topLayout.bottomAnchor).isActive = true
        firstHorizontalSeperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    
        scrollViewContainer.translatesAutoresizingMaskIntoConstraints = false
        scrollViewContainer.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        scrollViewContainer.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        scrollViewContainer.topAnchor.constraint(equalTo: firstHorizontalSeperator.bottomAnchor).isActive = true

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leftAnchor.constraint(equalTo: scrollViewContainer.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: scrollViewContainer.rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: scrollViewContainer.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: scrollViewContainer.bottomAnchor).isActive = true
        
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        seperator.leftAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -tracingViewWidth).isActive = true
        seperator.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        seperator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        secondHorizontalSeperator.translatesAutoresizingMaskIntoConstraints = false
        secondHorizontalSeperator.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        secondHorizontalSeperator.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        secondHorizontalSeperator.topAnchor.constraint(equalTo: scrollViewContainer.bottomAnchor).isActive = true
        secondHorizontalSeperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        bottomLayout.translatesAutoresizingMaskIntoConstraints = false
        bottomLayout.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        bottomLayout.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        bottomLayout.topAnchor.constraint(equalTo: secondHorizontalSeperator.bottomAnchor).isActive = true
        bottomLayout.heightAnchor.constraint(equalToConstant: codeLineHeight).isActive = true

        positionInformationTextLabel.sizeToFit()
        positionInformationTextLabel.translatesAutoresizingMaskIntoConstraints = false
        positionInformationTextLabel.leftAnchor.constraint(equalTo: bottomLayout.leftAnchor, constant: buttonOffset).isActive = true
        positionInformationTextLabel.centerYAnchor.constraint(equalTo: bottomLayout.centerYAnchor).isActive = true
        
        hiddenBox.translatesAutoresizingMaskIntoConstraints = false
        hiddenBox.leftAnchor.constraint(equalTo: positionInformationTextLabel.rightAnchor).isActive = true
        hiddenBox.centerYAnchor.constraint(equalTo: positionInformationTextLabel.centerYAnchor).isActive = true
        
        positionInformationDotsLabel.sizeToFit()
        positionInformationDotsLabel.translatesAutoresizingMaskIntoConstraints = false
        positionInformationDotsLabel.leftAnchor.constraint(equalTo: hiddenBox.rightAnchor).isActive = true
        positionInformationDotsLabel.centerYAnchor.constraint(equalTo: positionInformationTextLabel.centerYAnchor).isActive = true

        positionInformationValuesLabel.sizeToFit()
        positionInformationValuesLabel.translatesAutoresizingMaskIntoConstraints = false
        positionInformationValuesLabel.leftAnchor.constraint(equalTo: positionInformationDotsLabel.rightAnchor).isActive = true
        positionInformationValuesLabel.centerYAnchor.constraint(equalTo: positionInformationTextLabel.centerYAnchor).isActive = true

        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        keyboardView.leftAnchor.constraint(equalTo: codeView.leftAnchor).isActive = true
        keyboardView.rightAnchor.constraint(equalTo: codeView.rightAnchor).isActive = true
        keyboardView.bottomAnchor.constraint(equalTo: codeView.bottomAnchor).isActive = true
        keyboardHeightConstraint = NSLayoutConstraint(item: keyboardView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 3*buttonOffset+2*codeLineHeight)
        keyboardHeightConstraint.isActive = true
        keyboardView.topAnchor.constraint(equalTo: bottomLayout.bottomAnchor).isActive = true

        self.layoutIfNeeded()
        codeLinesView.frame = CGRect(x: 0, y: 0, width: scrollViewContainer.frame.width-tracingViewWidth, height: scrollViewContainer.frame.height)
        strokesBetweenCodeLinesView.frame = codeLinesView.frame
        strokesBetweenCodeLinesView.frame.origin.x += widthOfLineNumbers
        strokesBetweenCodeLinesView.frame.size.width -= widthOfLineNumbers
        
        codeTracingView.frame = CGRect(x: codeLinesView.frame.width+seperator.frame.width, y: -codeLineHeight, width: tracingViewWidth-1, height: scrollViewContainer.frame.height)
        
        
        
        traceButton.translatesAutoresizingMaskIntoConstraints = false
        traceButton.centerYAnchor.constraint(equalTo: bottomLayout.centerYAnchor).isActive = true
        traceButton.centerXAnchor.constraint(equalTo: seperator.rightAnchor, constant: tracingViewWidth/2).isActive = true
        traceButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        traceButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        nextStepButton.translatesAutoresizingMaskIntoConstraints = false
        nextStepButton.centerYAnchor.constraint(equalTo: traceButton.centerYAnchor).isActive = true
        nextStepButton.leftAnchor.constraint(equalTo: traceButton.rightAnchor, constant: buttonOffset).isActive = true
        nextStepButton.widthAnchor.constraint(equalTo: traceButton.widthAnchor).isActive = true
        nextStepButton.heightAnchor.constraint(equalTo: traceButton.heightAnchor).isActive = true

        previousStepButton.translatesAutoresizingMaskIntoConstraints = false
        previousStepButton.centerYAnchor.constraint(equalTo: traceButton.centerYAnchor).isActive = true
        previousStepButton.rightAnchor.constraint(equalTo: traceButton.leftAnchor, constant: -buttonOffset).isActive = true
        previousStepButton.widthAnchor.constraint(equalTo: traceButton.widthAnchor).isActive = true
        previousStepButton.heightAnchor.constraint(equalTo: traceButton.heightAnchor).isActive = true

        
        //buttons in keyboard view
        var xpos = buttonOffset
        var ypos = buttonOffset
        
        let initLineBuildCoordinates = CodeLineButton(lineType: .buildCoordinates)
        keyboardView.addSubview(initLineBuildCoordinates)
        setOfFixedCodeButtons.insert(initLineBuildCoordinates)
        initLineBuildCoordinates.frame.origin = CGPoint(x: xpos, y: ypos)

        ypos += initLineBuildCoordinates.frame.height+buttonOffset
        let initLineRemoveCoordinates = CodeLineButton(lineType: .removeCoordinates)
        keyboardView.addSubview(initLineRemoveCoordinates)
        setOfFixedCodeButtons.insert(initLineRemoveCoordinates)
        initLineRemoveCoordinates.frame.origin = CGPoint(x: xpos, y: ypos)
        
        xpos = buttonOffset+initLineBuildCoordinates.frame.width+buttonOffset
        ypos = buttonOffset
        
        let initLineBuildPosition = CodeLineButton(lineType: .buildPosition)
        keyboardView.addSubview(initLineBuildPosition)
        setOfVariableCodeButtons.insert(initLineBuildPosition)
        initLineBuildPosition.frame.origin = CGPoint(x: xpos, y: ypos)
        ypos += initLineBuildPosition.frame.height+buttonOffset
        
        xpos = buttonOffset+initLineRemoveCoordinates.frame.width+buttonOffset
        
        let initLineRemovePosition = CodeLineButton(lineType: .removePosition)
        keyboardView.addSubview(initLineRemovePosition)
        setOfVariableCodeButtons.insert(initLineRemovePosition)
        initLineRemovePosition.frame.origin = CGPoint(x: xpos, y: ypos)

        xpos = buttonOffset
        ypos += initLineRemovePosition.frame.height + buttonOffset
        let initLineLoopStart = CodeLineButton(lineType: .loopStart)
        keyboardView.addSubview(initLineLoopStart)
        setOfLoopCodeButtons.insert(initLineLoopStart)
        initLineLoopStart.frame.origin = CGPoint(x: xpos, y: ypos)
        
        ypos += initLineLoopStart.frame.height+buttonOffset
        let initLineSetPosition = CodeLineButton(lineType: .setPosition)
        keyboardView.addSubview(initLineSetPosition)
        setOfVariableCodeButtons.insert(initLineSetPosition)
        initLineSetPosition.frame.origin = CGPoint(x: xpos, y: ypos)
        xpos += initLineSetPosition.frame.width+buttonOffset
        
        
        let initLineChangePosition = CodeLineButton(lineType: .changePosition)
        keyboardView.addSubview(initLineChangePosition)
        setOfVariableCodeButtons.insert(initLineChangePosition)
        initLineChangePosition.frame.origin = CGPoint(x: xpos, y: ypos)
        
    

        renewEnabilityOfCodeButtons()
        renewTextViewContentHeight()
        

    }
    
    override func layoutSubviews() {
        codeLinesView.frame = CGRect(x: 0, y: 0, width: scrollViewContainer.frame.width-tracingViewWidth, height: scrollViewContainer.frame.height)

    }
    
    func floatByBool(bool: Bool) -> CGFloat{
        return bool ? 1 : 0
    }
    
    func renewEnabilityOfCodeButtons(){
        
        for button in setOfVariableCodeButtons{
            button.isVisible = variablesAreEnabled
        }
        for button in setOfLoopCodeButtons{
            button.isVisible = loopsAreEnabled
        }
        for button in setOfFixedCodeButtons.union(setOfVariableCodeButtons).union(setOfLoopCodeButtons){
            button.isEnabled = true
        }

        keyboardView.contentSize.width = setOfVariableCodeButtons.sorted(by: {$0.frame.origin.x+$0.frame.width < $1.frame.origin.x+$1.frame.width}).last!.frame.origin.x+setOfVariableCodeButtons.sorted(by: {$0.frame.origin.x+$0.frame.width < $1.frame.origin.x+$1.frame.width}).last!.frame.width+buttonOffset

        
        
        if(variablesAreEnabled && loopsAreEnabled){
            keyboardHeightConstraint.constant = 5*buttonOffset+4*codeLineHeight
            for button in setOfVariableCodeButtons.filter({$0.currentCodeLineType == .setPosition || $0.currentCodeLineType == .changePosition}){
                button.frame.origin.y = setOfLoopCodeButtons.first!.frame.origin.y+setOfLoopCodeButtons.first!.frame.height+buttonOffset
            }
        }
        else{
            if(variablesAreEnabled || loopsAreEnabled){
                keyboardHeightConstraint.constant = 4*buttonOffset+3*codeLineHeight
                if(variablesAreEnabled){
                    for button in setOfVariableCodeButtons.filter({$0.currentCodeLineType == .setPosition || $0.currentCodeLineType == .changePosition}){
                        button.frame.origin.y = setOfLoopCodeButtons.first!.frame.origin.y
                    }
                }
            }
            else{
                keyboardHeightConstraint.constant = 3*buttonOffset+2*codeLineHeight
            }
        }
        keyboardView.setNeedsLayout()
    }
    

    
    @objc func panInsertView(sender: UIPanGestureRecognizer){
        insertLineNumber = lineNumberByDisplayPosition(sender.location(in: scrollView).y+codeLineHeight/2)
        if(insertLineNumber < 1){
            insertLineNumber = 1
        }
        if(insertLineNumber > setOfCodeLines.count+1){
            insertLineNumber = setOfCodeLines.count+1
        }
        insertCodeLineNumberIndicator.center.y = displayPositionByLineNumber(insertLineNumber, depth: 0).y
        if(insertLineNumber == 1){
            insertCodeLineNumberIndicator.center.y = displayPositionByLineNumber(insertLineNumber, depth: 0).y+5
        }
        renewTextViewContentHeight()
    }
    

    //Erneuere Höhe des Textfeldes (damit ordentlich gescrollt werden kann)
    func renewTextViewContentHeight(){
        scrollView.contentSize.height = max(scrollViewContainer.frame.height, CGFloat(setOfCodeLines.count+1)*codeLineHeight+20)
        codeLinesView.frame.size.height = scrollView.contentSize.height
        codeTracingView.frame.size.height = scrollView.contentSize.height
        strokesBetweenCodeLinesView.frame.size.height = codeLinesView.frame.height
        if(insertCodeLineNumberIndicator.center.y+codeLineHeight-scrollView.frame.height > scrollView.contentOffset.y){
            scrollView.setContentOffset(CGPoint(x: 0, y: insertCodeLineNumberIndicator.center.y+codeLineHeight-scrollView.frame.height), animated: true)
        }
        if(insertCodeLineNumberIndicator.center.y-codeLineHeight < scrollView.contentOffset.y){
            scrollView.setContentOffset(CGPoint(x: 0, y: max(0,insertCodeLineNumberIndicator.center.y-codeLineHeight)), animated: true)
        }
        if(scrollView.contentOffset.y < 0){
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    
    
    
    
    
    
    //### Code ausführen ###//

    
    
    
    func moveTo(codeLine: CodeLine){
        if(unloopedCodeLines.count>1 && currentCodeStep >= 1 && unloopedCodeLines[currentCodeStep-1] is CodeLineLoopEnd && !codeLine.setOfFixedCodeLines.contains(unloopedCodeLines[currentCodeStep-1])){
            let animation = CAKeyframeAnimation(keyPath: "position")
            let path = UIBezierPath()
            path.move(to: CGPoint(x: tracingViewWidth/2, y: codeLine.frame.origin.y+codeLineHeight/2))
            path.addLine(to: CGPoint(x: tracingViewWidth/2-codeLineHeight/4, y: codeLine.frame.origin.y+codeLineHeight/2+codeLineHeight/4))
            path.addLine(to: CGPoint(x: tracingViewWidth/2, y: codeLine.frame.origin.y+codeLineHeight/2+codeLineHeight/2))
            path.addLine(to: CGPoint(x: tracingViewWidth/2, y: codeLine.frame.origin.y+3*codeLineHeight/2))
            animation.path = path.cgPath
            animation.duration = 0.2
            animation.repeatCount = 0
            codeTracingView.currentActionCirlce.layer.add(animation, forKey: "animate position along path")
            codeTracingView.currentActionCirlce.center.y = codeLine.frame.origin.y+3*codeLineHeight/2
        }
        else{
            UIView.animate(withDuration: 0.2, animations: {
                self.codeTracingView.currentActionCirlce.center.y = codeLine.frame.origin.y+3*codeLineHeight/2
            })
        }
        
    }
    func moveTo(position: CGFloat){
        if(unloopedCodeLines.count>1 && currentCodeStep >= 1 && unloopedCodeLines[currentCodeStep-1] is CodeLineLoopEnd){
            let animation = CAKeyframeAnimation(keyPath: "position")
            let path = UIBezierPath()
            path.move(to: CGPoint(x: tracingViewWidth/2, y: position-codeLineHeight))
            path.addLine(to: CGPoint(x: tracingViewWidth/2-codeLineHeight/4, y: position-codeLineHeight+codeLineHeight/4))
            path.addLine(to: CGPoint(x: tracingViewWidth/2, y: position-codeLineHeight+codeLineHeight/2))
            path.addLine(to: CGPoint(x: tracingViewWidth/2, y: position))
            animation.path = path.cgPath
            animation.duration = 0.2
            animation.repeatCount = 0
            codeTracingView.currentActionCirlce.layer.add(animation, forKey: "animate position along path")
            codeTracingView.currentActionCirlce.center.y = position
        }
        else{
            UIView.animate(withDuration: 0.2, animations: {
                self.codeTracingView.currentActionCirlce.center.y = position
            })
        }
    }
    
    func moveBackwardsTo(codeLine: CodeLine){
           if(codeLine is CodeLineLoopEnd){
               let animation = CAKeyframeAnimation(keyPath: "position")
               let path = UIBezierPath()
               path.move(to: CGPoint(x: tracingViewWidth/2, y: codeLine.frame.origin.y+5*codeLineHeight/2))
               path.addLine(to: CGPoint(x: tracingViewWidth/2, y: codeLine.frame.origin.y+4*codeLineHeight/2))
               path.addLine(to: CGPoint(x: tracingViewWidth/2-codeLineHeight/4, y: codeLine.frame.origin.y+4*codeLineHeight/2-codeLineHeight/4))
               path.addLine(to: CGPoint(x: tracingViewWidth/2, y: codeLine.frame.origin.y+3*codeLineHeight/2))
               animation.path = path.cgPath
               animation.duration = 0.2
               animation.repeatCount = 0
               codeTracingView.currentActionCirlce.layer.add(animation, forKey: "animate position along path")
               codeTracingView.currentActionCirlce.center.y = codeLine.frame.origin.y+3*codeLineHeight/2
           }
           else{
               UIView.animate(withDuration: 0.2, animations: {
                   self.codeTracingView.currentActionCirlce.center.y = codeLine.frame.origin.y+3*codeLineHeight/2
               })
           }
           
       }
    
    
    
    
    
    
    @objc func nextStep(){
        
        previousStepButton.isEnabled = true
        currentCodeStep += 1

        //any line step
        if(currentCodeStep < unloopedCodeLines.count){

            let trackedCodeLine = unloopedCodeLines[self.currentCodeStep]
            
            //if line is loop start
            if let startLine = trackedCodeLine as? CodeLineLoopStart{
                //first reachment of loop
                if(self.currentCodeStep==0 || (self.currentCodeStep>0 && !startLine.setOfFixedCodeLines.contains(unloopedCodeLines[self.currentCodeStep-1]))){
                    startLine.currentTracingStep = 1
                    moveTo(codeLine: trackedCodeLine)
                }
                //later reachment of loop
                else{
                    startLine.currentTracingStep += 1
                    let animation = CAKeyframeAnimation(keyPath: "position")
                    let path = UIBezierPath()
                    path.move(to: CGPoint(x: tracingViewWidth/2, y: startLine.connectedEndLine.frame.origin.y+3*codeLineHeight/2))
                    path.addLine(to: CGPoint(x: tracingViewWidth/2+codeLineHeight/4, y: startLine.connectedEndLine.frame.origin.y+3*codeLineHeight/2+codeLineHeight/4))
                    path.addLine(to: CGPoint(x: tracingViewWidth/2+self.codeTracingView.widthByLoopDepth(depth: startLine.loopDepth), y: startLine.connectedEndLine.frame.origin.y+3*codeLineHeight/2+codeLineHeight/4))
                    path.addLine(to: CGPoint(x: tracingViewWidth/2+self.codeTracingView.widthByLoopDepth(depth: startLine.loopDepth), y: startLine.frame.origin.y+3*codeLineHeight/2))
                    path.addLine(to: CGPoint(x: tracingViewWidth/2, y: startLine.frame.origin.y+3*codeLineHeight/2))
                    animation.path = path.cgPath
                    animation.duration = 0.2
                    animation.repeatCount = 0
                    codeTracingView.currentActionCirlce.layer.add(animation, forKey: "animate position along path")
                    codeTracingView.currentActionCirlce.center.y = startLine.frame.origin.y+3*codeLineHeight/2
                }
            }
            //none loop start
            else{
                moveTo(codeLine: trackedCodeLine)
                if(trackedCodeLine is CodeLineLoopEnd){
                    UIView.animate(withDuration: 0.2, animations: {
                        self.codeTracingView.currentActionCirlce.transform = self.codeTracingView.currentActionCirlce.transform.rotated(by: -CGFloat.pi/4)
                    })
                }
            }
            showSomeCubes(listOfCodeLines: Array(unloopedCodeLines[0...currentCodeStep]))
            sceneView.renewOtherViews()

        }
        //last step
        else{
            moveTo(position: (CGFloat(setOfCodeLines.count)+1.5)*codeLineHeight)
            nextStepButton.isEnabled = false
        }
                
        
        codeTracingView.setNeedsDisplay()
        setInformation()
    }

    
    
    
    @objc func previousStep(){
        
        nextStepButton.isEnabled = true

        //any line step
        if(currentCodeStep > 0){

            currentCodeStep -= 1

            let trackedCodeLine = unloopedCodeLines[self.currentCodeStep]

            if let endLine = trackedCodeLine as? CodeLineLoopEnd{
                let startLine = setOfCodeLines.first(where: {$0 is CodeLineLoopStart && ($0 as! CodeLineLoopStart).connectedEndLine == endLine})! as! CodeLineLoopStart
                //earlier reachment of loop end
                if(self.currentCodeStep+1 < unloopedCodeLines.count &&  unloopedCodeLines[self.currentCodeStep+1] == startLine){
                    startLine.currentTracingStep -= 1
                    let animation = CAKeyframeAnimation(keyPath: "position")
                    let path = UIBezierPath()
                    path.move(to: CGPoint(x: tracingViewWidth/2, y: startLine.frame.origin.y+3*codeLineHeight/2))
                    path.addLine(to: CGPoint(x: tracingViewWidth/2+self.codeTracingView.widthByLoopDepth(depth: startLine.loopDepth), y: startLine.frame.origin.y+3*codeLineHeight/2))
                    path.addLine(to: CGPoint(x: tracingViewWidth/2+self.codeTracingView.widthByLoopDepth(depth: startLine.loopDepth), y: trackedCodeLine.frame.origin.y+3*codeLineHeight/2+codeLineHeight/4))
                    path.addLine(to: CGPoint(x: tracingViewWidth/2+codeLineHeight/4, y: trackedCodeLine.frame.origin.y+3*codeLineHeight/2+codeLineHeight/4))
                    path.addLine(to: CGPoint(x: tracingViewWidth/2, y: trackedCodeLine.frame.origin.y+3*codeLineHeight/2))
                    animation.path = path.cgPath
                    animation.duration = 0.2
                    animation.repeatCount = 0
                    codeTracingView.currentActionCirlce.layer.add(animation, forKey: "animate position along path")
                    codeTracingView.currentActionCirlce.center.y = trackedCodeLine.frame.origin.y+3*codeLineHeight/2
                }
                //last reachment of loop end
                else{
                    startLine.currentTracingStep = startLine.listOfValues[0].value
                    moveBackwardsTo(codeLine: trackedCodeLine)
                }
            }
            else{
                moveBackwardsTo(codeLine: trackedCodeLine)

            }

            
            
            showSomeCubes(listOfCodeLines: Array(unloopedCodeLines[0...currentCodeStep]))
            sceneView.renewOtherViews()
        }

        //first step
        else{
            showSomeCubes(listOfCodeLines: [])
            sceneView.renewOtherViews()

            
            currentCodeStep = -1
            UIView.animate(withDuration: 0.2, animations: {
                self.codeTracingView.currentActionCirlce.center.y = codeLineHeight/2
            })

            previousStepButton.isEnabled = false

        }
        codeTracingView.setNeedsDisplay()



        setInformation()
    }

    func setInformation(){

        if(listOfStringValues.first(where: {$0[0] == hiddenBox.value}) != nil){
            positionInformationValuesLabel.font = UIFont(name: "Menlo", size: characterSize)
            positionInformationValuesLabel.text = "(\(listOfStringValues.first(where: {$0[0] == hiddenBox.value})![1]),\(listOfStringValues.first(where: {$0[0] == hiddenBox.value})![2]))"
        }
        else if(hiddenBox.value == 0){
            positionInformationValuesLabel.text = ""
        }
        else{
            positionInformationValuesLabel.font = UIFont(name: positionInformationTextLabel.font.familyName, size: characterSize)
            positionInformationValuesLabel.text = NSLocalizedString("InfoPositionNotSet", comment: "InfoPositionNotSet")
        }
    }
    

    
    @objc func traceCode(){

        //start code tracking
        if(codeIsTracing == false){

            insertCodeLineNumberIndicator.alpha = 0
            codeLinesView.isUserInteractionEnabled = false
            for line in setOfCodeLines{
                line.handleView.alpha = 0
            }
            codeTracingView.alpha = 1
            
            sceneView.codeTracingOverlay.alpha = 1
            sceneView.cubeOpacity = 1
            planView.codeTracingOverlay.alpha = 1
            

            showSomeCubes(listOfCodeLines: [])

            
            for button in setOfFixedCodeButtons.union(setOfVariableCodeButtons).union(setOfLoopCodeButtons){
                button.isEnabled = false
            }
            if #available(iOS 13.0, *) {
                traceButton.setImage(UIImage.init(systemName: "stop.circle"), for: .normal)
            } else {
                traceButton.setImage(UIImage(named: "stopCircle"), for: .normal)
            }
            for view in viewsToChangeVisibility{
                view.alpha = 1
            }

            codeIsTracing = true

            currentCodeStep = -1
            nextStepButton.isEnabled = true
            previousStepButton.isEnabled = false
            
            setInformation()
            

            scrollView.setContentOffset(CGPoint(x: 0, y: -codeLineHeight), animated: true)

            codeTracingView.currentActionCirlce.center.y = codeLineHeight/2

            
            for line in setOfCodeLines{
                for valueBox in line.listOfValues{
                    valueBox.backgroundColor = valueBox.boxColor.withAlphaComponent(0.075)
                }
            }
            
        }

        else{
            endCodeTracing()
        }
        codeTracingView.setNeedsDisplay()

    }
    
    func endCodeTracing(){
        
        
        insertCodeLineNumberIndicator.alpha = 1
        codeLinesView.isUserInteractionEnabled = true
        for line in setOfCodeLines{
            line.handleView.alpha = 1
        }

        codeTracingView.alpha = 0

        renewTextViewContentHeight()

        showAllCubes()

        for button in setOfFixedCodeButtons.union(setOfVariableCodeButtons).union(setOfLoopCodeButtons){
            button.isEnabled = true
        }


        for startLine in setOfCodeLines.filter({$0 is CodeLineLoopStart}){
            (startLine as! CodeLineLoopStart).currentTracingStep = 0
        }

        if #available(iOS 13.0, *) {
            traceButton.setImage(UIImage.init(systemName: "play.circle"), for: .normal)
        } else {
            traceButton.setImage(UIImage(named: "playCircle"), for: .normal)
        }

        for view in viewsToChangeVisibility{
            view.alpha = 0
        }


        sceneView.codeTracingOverlay.alpha = 0
        planView.codeTracingOverlay.alpha = 0

        codeIsTracing = false

        for line in setOfCodeLines{
            for valueBox in line.listOfValues{
                valueBox.backgroundColor = valueBox.boxColor.withAlphaComponent(0.2)
            }
        }
        
    }
    
    
    
    
    
    

    
    

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if(sceneView.cubesAreVisible == false){
            sceneView.cubesAreVisible = true
            for cubeNode in sceneView.setOfCubesNodes{
                cubeNode.opacity = 1
            }
            sceneView.cubeOpacity = 1
        }
        
        return super.hitTest(point, with: event)
    }
    
    
    
    
    
    
    

    

    

    func unloopCodeLines(lineNumberRange : ClosedRange<Int>){
        
        if(lineNumberRange.lowerBound == 1){
            unloopedCodeLines = []
        }
        
        var i = lineNumberRange.lowerBound
        while(i <= lineNumberRange.upperBound){
            if let interestedLine = setOfCodeLines.first(where: {$0.lineNumber == i}){
                switch interestedLine {
                case is CodeLineLoopStart:
                    let interestedStartLine = interestedLine as! CodeLineLoopStart
                    if(interestedStartLine.listOfValues.first!.valueIsSet){
                        for _ in 0..<interestedStartLine.listOfValues.first!.value{
                            unloopedCodeLines.append(interestedLine)
                            
                            unloopCodeLines(lineNumberRange: interestedStartLine.lineNumber+1...interestedStartLine.connectedEndLine.lineNumber)
                        }
                    }
                    i += interestedStartLine.connectedEndLine.lineNumber-interestedStartLine.lineNumber
                    break
                case is CodeLineLoopEnd:
                    unloopedCodeLines.append(interestedLine)
                    
                default:
                    var isAddable = Bool(true)
                    for value in interestedLine.listOfValues{
                        if(!value.valueIsSet){
                            isAddable = false
                        }
                    }
                    if(isAddable == true){
                        unloopedCodeLines.append(interestedLine)
                    }
                }
            }
            i+=1
        }
    }
    
    
    

    
    func calcNewCubes(listOfCodeLine : [CodeLine]) -> Set<Cube> {
        var newSetOfCodeCubes : Set<Cube> = []
        let floorCube = Cube(x: -1, y: -1, z: 0, visited: false)
        
        newSetOfCodeCubes.insert(floorCube)
        
        listOfStringValues = []

        for codeLine in listOfCodeLine{
            if(codeLine is CodeLineSetPosition){
                if(codeLine.listOfValues[1].valueIsSet && codeLine.listOfValues[2].valueIsSet){
                    var valueIsExisting = Bool(false)
                    for i in 0 ..< listOfStringValues.count{
                        if(listOfStringValues[i][0] == codeLine.listOfValues[0].value && codeLine.listOfValues[1].valueIsSet && codeLine.listOfValues[2].valueIsSet){
                            valueIsExisting = true
                            listOfStringValues[i][1] = codeLine.listOfValues[1].value
                            listOfStringValues[i][2] = codeLine.listOfValues[2].value
                        }
                    }
                    if(!valueIsExisting){
                        listOfStringValues += [[codeLine.listOfValues[0].value,codeLine.listOfValues[1].value,codeLine.listOfValues[2].value]]
                    }
                }
            }
            
            if(codeLine is CodeLineChangePosition){

                for i in 0 ..< listOfStringValues.count{
                    if(listOfStringValues[i][0] == codeLine.listOfValues[0].value && codeLine.listOfValues[1].valueIsSet && codeLine.listOfValues[2].valueIsSet){
                        listOfStringValues[i][1] += codeLine.listOfValues[1].value
                        listOfStringValues[i][2] += codeLine.listOfValues[2].value
                    }
                }
            }
            
            if(codeLine is CodeLineBuildCoordinates){
                
                let greenNumber = codeLine.listOfValues[0].value
                let blueNumber = codeLine.listOfValues[1].value
                
                var height = Int(1)
                for cube in newSetOfCodeCubes{
                    if(cube.x==greenNumber && cube.y==blueNumber){
                        height += 1
                    }
                }
                //Ziehe ab, weil floorCube an der Stelle ist
                if(greenNumber == -1 && blueNumber == -1){
                    height -= 1
                }
                
                
                if(codeLine.listOfValues[0].valueIsSet == true && codeLine.listOfValues[1].valueIsSet == true){
                    let newCube = Cube(x: greenNumber, y: blueNumber, z: height, visited: false)
                    newSetOfCodeCubes.insert(newCube)
                }
                else{
                }
            }
            
            
            
            if(codeLine is CodeLineBuildPosition){
                
                var valueIsSet = Bool(false)
                var greenNumber = 0
                var blueNumber = 0
                
                
                for stringValue in listOfStringValues{
                    if(stringValue[0] == codeLine.listOfValues[0].value){
                        greenNumber = stringValue[1]
                        blueNumber = stringValue[2]
                        valueIsSet = true
                    }
                }
                
                
                
                if(valueIsSet){
                    var height = Int(1)
                    for cube in newSetOfCodeCubes{
                        if(cube.x==greenNumber && cube.y==blueNumber){
                            height += 1
                        }
                    }
                    //Ziehe ab, weil floorCube an der Stelle ist
                    if(greenNumber == -1 && blueNumber == -1){
                        height -= 1
                    }
                    
                    if(codeLine.listOfValues[0].valueIsSet == true){
                        
                        let newCube = Cube(x: greenNumber, y: blueNumber, z: height, visited: false)
                        newSetOfCodeCubes.insert(newCube)
                    }
                }
                else{
                }
                
            }
            
            
            if(codeLine is CodeLineRemoveCoordinates){
                
                let greenNumber = codeLine.listOfValues[0].value
                let blueNumber = codeLine.listOfValues[1].value
                
                var height = Int(0)
                for cube in newSetOfCodeCubes{
                    if(cube.x==greenNumber && cube.y==blueNumber){
                        height += 1
                    }
                }
                //Ziehe ab, weil floorCube an der Stelle ist
                if(greenNumber == -1 && blueNumber == -1){
                    height -= 1
                }
                
                if(codeLine.listOfValues[0].valueIsSet == true && codeLine.listOfValues[1].valueIsSet == true){
                    let newCube = Cube(x: greenNumber, y: blueNumber, z: height, visited: false)
                    newSetOfCodeCubes.remove(newCube)
                }
                else{
                }
            }
            
            if(codeLine is CodeLineRemovePosition){
                
                var valueIsSet = Bool(false)
                var greenNumber = 0
                var blueNumber = 0
                
                for stringValue in listOfStringValues{
                    if(stringValue[0] == codeLine.listOfValues[0].value){
                        greenNumber = stringValue[1]
                        blueNumber = stringValue[2]
                        valueIsSet = true
                    }
                }
                
                if(valueIsSet){
                    var height = Int(0)
                    for cube in newSetOfCodeCubes{
                        if(cube.x==greenNumber && cube.y==blueNumber){
                            height += 1
                        }
                    }
                    //Ziehe ab, weil floorCube an der Stelle ist
                    if(greenNumber == -1 && blueNumber == -1){
                        height -= 1
                    }
                    
                    if(codeLine.listOfValues[0].valueIsSet == true){
                        let newCube = Cube(x: greenNumber, y: blueNumber, z: height, visited: false)
                        newSetOfCodeCubes.remove(newCube)
                    }
                }
                else{
                }
            }
            
            
            
        }
        return newSetOfCodeCubes
    }
    
    
    func showAllCubes(){

        if(!setOfCodeLines.isEmpty){
            unloopCodeLines(lineNumberRange: 1...setOfCodeLines.count)
            showSomeCubes(listOfCodeLines: unloopedCodeLines)
            sceneView.renewOtherViews()
        }
    }
    

    
    func showSomeCubes(listOfCodeLines: [CodeLine]){
        
        let cubes = calcNewCubes(listOfCodeLine: listOfCodeLines)


        //new added cubes
        for cube in cubes.subtracting(setOfCubes).filter({$0.z != 0}) {
            sceneView.addCube(x: cube.x, y: cube.y, z: cube.z)
        }

        //new removed cubes
        for cube in setOfCubes.subtracting(cubes) {
            for someCubeNode in sceneView.setOfCubesNodes.filter({$0.x == cube.x && $0.y == cube.y && $0.z == cube.z}){
                sceneView.removeCube(cubeNode: someCubeNode)
            }
        }
        setOfCubes = cubes


    }
    

    func lastIdentifier() -> Int{
        return (setOfStructCodeLines.sorted(by: {$0.identifier < $1.identifier}).last?.identifier ?? 0) + 1
    }
    
    func addEmptyStructCodeLine(type: CodeLineTypes){
        let structCodeLine = StructCodeLine(identifier: lastIdentifier(), values: [], lineType: type, lineNumber: insertLineNumber)
        setOfStructCodeLines.insert(structCodeLine)
    }
    
    
    func addCodeLine(type: CodeLineTypes) -> CodeLine{
        
        var offset = 0
        for line in setOfCodeLines.filter({$0.lineNumber >= codeView.insertLineNumber}).sorted(by: {$0.lineNumber < $1.lineNumber}){
            if(type == .loopStart){
                offset=1
            }
            line.lineNumber += 1+offset
            line.topConstraint.constant = displayPositionByLineNumber(line.lineNumber, depth: line.loopDepth).y
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.codeLinesView.layoutIfNeeded()
        })



        var newLine = CodeLine(lineNumber: 0)
        switch type {
        case .buildCoordinates:
            newLine = CodeLineBuildCoordinates(lineNumber: insertLineNumber)
        case .buildPosition:
            newLine = CodeLineBuildPosition(lineNumber: insertLineNumber)
        case .removeCoordinates:
            newLine = CodeLineRemoveCoordinates(lineNumber: insertLineNumber)
        case .removePosition:
            newLine = CodeLineRemovePosition(lineNumber: insertLineNumber)
        case .setPosition:
            newLine = CodeLineSetPosition(lineNumber: insertLineNumber)
        case .changePosition:
            newLine = CodeLineChangePosition(lineNumber: insertLineNumber)
        case .loopStart:
            newLine = CodeLineLoopStart(lineNumber: insertLineNumber)

            let endLine = CodeLineLoopEnd(lineNumber: insertLineNumber+1)
            setOfCodeLines.insert(endLine)
            codeLinesView.addSubview(endLine)
            endLine.translatesAutoresizingMaskIntoConstraints = false
            endLine.leftAnchor.constraint(equalTo: codeView.codeLinesView.leftAnchor).isActive = true
            endLine.heightAnchor.constraint(equalToConstant: codeLineHeight).isActive = true
            endLine.topConstraint = endLine.topAnchor.constraint(equalTo: codeView.codeLinesView.topAnchor, constant: displayPositionByLineNumber(endLine.lineNumber, depth: endLine.loopDepth).y)
            endLine.topConstraint.isActive = true
            endLine.rightAnchor.constraint(equalTo: codeView.codeLinesView.rightAnchor).isActive = true

            (newLine as! CodeLineLoopStart).connectedEndLine = endLine
            newLine.setOfFixedCodeLines.insert(endLine)
            endLine.renewCodeLine()
        default:
            break
        }
        setOfCodeLines.insert(newLine)





        codeLinesView.addSubview(newLine)
        updateLineNumbers()


        newLine.translatesAutoresizingMaskIntoConstraints = false
        newLine.leftAnchor.constraint(equalTo: codeView.codeLinesView.leftAnchor).isActive = true
        newLine.heightAnchor.constraint(equalToConstant: codeLineHeight).isActive = true
        newLine.topConstraint = newLine.topAnchor.constraint(equalTo: codeView.codeLinesView.topAnchor, constant: displayPositionByLineNumber(newLine.lineNumber, depth: newLine.loopDepth).y)
        newLine.topConstraint.isActive = true
        newLine.rightAnchor.constraint(equalTo: codeView.codeLinesView.rightAnchor).isActive = true



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
            line.renewCodeLine()
            (line as! CodeLineLoopStart).connectedEndLine.renewCodeLine()

        }

        insertLineNumber += 1

        UIView.animate(withDuration: 0.2, animations: {
            self.insertCodeLineNumberIndicator.center.y = displayPositionByLineNumber(self.insertLineNumber, depth: 0).y
        })


        renewTextViewContentHeight()

        newLine.loopDepth = setOfCodeLines.filter({$0.lineNumber < newLine.lineNumber && $0 is CodeLineLoopStart}).count-setOfCodeLines.filter({$0.lineNumber <= newLine.lineNumber && $0 is CodeLineLoopEnd}).count
        if(newLine is CodeLineLoopStart){
            (newLine as! CodeLineLoopStart).connectedEndLine.loopDepth = newLine.loopDepth
            (newLine as! CodeLineLoopStart).connectedEndLine.renewCodeLine()
        }
        newLine.renewCodeLine()

        
        return newLine

        
        
    }
    
    
    func updateLineNumbers(){

        
        while lineNumbers.count < setOfCodeLines.count {
            let newLineNumber = UILabel(frame: CGRect(x: 0, y: CGFloat(lineNumbers.count)*(codeLineHeight), width: widthOfLineNumbers, height: codeLineHeight))
            
            
            newLineNumber.font = UIFont(name: "Menlo", size: characterSize)
            newLineNumber.textColor = .systemGray

            
            
            newLineNumber.text = "\(lineNumbers.count+1)"
            newLineNumber.textAlignment = .right
            scrollView.addSubview(newLineNumber)
            lineNumbers.append(newLineNumber)
        }
        while lineNumbers.count > setOfCodeLines.count {
            lineNumbers.last?.removeFromSuperview()
            lineNumbers.removeLast()
        }

    }
    
    

    
    
    
}
        
