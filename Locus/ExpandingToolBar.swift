//
//  ExpandingToolBar.swift
//  ExpandingToolBar
//
//  Created by Nabil K on 2017-01-26.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit

class ExpandingToolBar: UIView {

    private var maxSize: CGFloat = 0
    private var minSize: CGFloat = 0
    var canExpand: Bool = true
    var colors:[UIColor] = [UIColor.red, UIColor.blue, UIColor.green]
    public private(set) var isExpanded = false
    public private(set) var actions = [ToolbarAction]()
    public private(set) var numActions: CGFloat = 1
    var buttonSize: CGFloat = 0
    var expandButton: UIButton?
    var buttonBorderWidth: CGFloat = 1
    var buttonBorderColor = UIColor.black.cgColor
    var buttonColor = UIColor.gray
    
    var direction: Direction = .south{
        
        didSet{
            self.isExpanded = false
            contractActionButtons()
        }
    }
    
    var panDelegate: Pannable?
    
    
    
    // TODO: Refactor the updates below
    var panable: Bool = true{
        didSet{
            panStatusChanged()
        }
    }
    
    
    var slideable: Bool = true{
        
        didSet{
            slideStatusChanged()
        }
    }
    
    
    init(frame: CGRect, buttonSize: CGFloat?) {
        
        //Min size must be symmetrical
        
        if let buttonSize = buttonSize{
            self.buttonSize = buttonSize
        }
        
        else {
            
            self.buttonSize = minSize
            
        }

        
        self.minSize = min(frame.width, frame.height)
       
        self.maxSize = max(frame.width, frame.height, minSize*CGFloat(actions.count), self.buttonSize*CGFloat(actions.count))
        
        self.buttonSize = self.minSize

        let newFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: minSize, height: minSize)
        
        super.init(frame: newFrame)
        
        
        self.backgroundColor = UIColor.red
        self.clipsToBounds = true
        self.layer.cornerRadius = 5
        
        buildExpandButton()
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    
    private func buildExpandButton(){
        let buttonRect = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: minSize, height: minSize)
        expandButton = UIButton(frame: buttonRect)
        
        if let expandButton = expandButton {

            self.addSubview(expandButton)
            expandButton.backgroundColor = UIColor.gray
            expandButton.addTarget(self, action: #selector(expand), for: .touchUpInside)
            expandButton.setTitle("+", for: .normal)
            expandButton.clipsToBounds = true
        }
    }
    
     func expand(){
        print("tapped")
        if !isExpanded {
            let newFrames = rectForDirection(direction: self.direction)
            UIView.animate(withDuration: 0.5) { [unowned self] in
                self.frame = newFrames.base
                self.expandButton!.frame = newFrames.sub
            }
            layoutActionButtons()
        }
        else {
            UIView.animate(withDuration: 0.5) { [unowned self] in
                let originalFrame = self.rectForContractionFrom(direction: self.direction)
                self.frame = originalFrame
                self.expandButton!.frame.origin = CGPoint(x: 0, y: 0)
            }
            contractActionButtons()
        }
        isExpanded = !isExpanded
    }
    
    func addAction(title:String?,font: UIFont?, image: UIImage?, color: UIColor?, action:  @escaping () -> ()){
        self.numActions += 1
        let x = self.bounds.origin.x
        let y = self.bounds.origin.y
        
        let buttonRect = CGRect(x: x, y: y, width: minSize, height: minSize)
        
        
        let button = ToolbarButton(frame: buttonRect)
        
        
        // TODO: Refactor following paragraphs
        button.backgroundColor = UIColor.brown
        button.layer.borderWidth = self.buttonBorderWidth
        button.layer.borderColor = self.buttonBorderColor
        button.addTarget(self, action: #selector(triggerAction(sender:)), for: .touchUpInside)
        
        if let title = title{
            button.setTitle(title, for: .normal)
            button.titleLabel?.sizeToFit()
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.1
        }
        

        button.clipsToBounds = true
        
        
        if let font = font{
            button.setFont(font: font)
        }
        
        if let image = image{
            
            button.imageView?.contentMode = .scaleAspectFit
            button.setImage(image, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

        
        }
        
        if let color = color{
            button.backgroundColor = color
        }
        
        
        let toolbarAction = ToolbarAction(button: button, image:image, action: action)
        actions.append(toolbarAction)
    }

    
    private func layoutActionButtons(){
        UIView.animate(withDuration: 0.5) { [unowned self] in
            guard self.actions.count > 1 else {return}
            
            for i in 1...self.actions.count {
                self.addSubview(self.actions[i - 1].button)
                let thisAction = self.actions[i - 1]
                let coordinates = self.coordinatesForDirection(direction: self.direction, position: i)
                
                let x = coordinates.x
                let y = coordinates.y
                thisAction.button.frame.origin = CGPoint(x: x, y: y)
            }
            self.exchangeSubview(at: 0, withSubviewAt: self.actions.count)
        }
    }
    
    private func coordinatesForDirection(direction: Direction, position: Int) -> (x: CGFloat, y: CGFloat){
        var x: CGFloat
        var y: CGFloat
        
        switch(direction){
        case .east:
            x = self.bounds.origin.x + self.minSize*CGFloat(position)
            y = self.bounds.origin.y
        case .west:
            x = self.maxSize - minSize*CGFloat(position + 1)
            y = self.bounds.origin.y
        case .south:
            x = self.bounds.origin.x
            y = self.bounds.origin.y + self.minSize*CGFloat(position)
        case .north:
            x = self.bounds.origin.x
            y = self.maxSize - minSize*CGFloat(position + 1)
        }
        return (x,y)
    }
    
    private func rectForContractionFrom(direction: Direction) -> CGRect{
        switch direction {
        case .east, .south:
            return CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.minSize, height: self.minSize)
        case .west:
            return CGRect(x: self.frame.origin.x + maxSize - minSize, y: self.frame.origin.y, width: minSize, height: minSize)
        case .north:
            return CGRect(x: self.frame.origin.x, y: self.frame.origin.y + maxSize - minSize, width: minSize, height: minSize)
        }
    }
    
    

    private func contractActionButtons(){
       UIView.animate(withDuration: 0.5, animations: {
        for i in 0..<self.actions.count {
            let thisAction = self.actions[i]
            thisAction.button.frame.origin = self.bounds.origin
        }
       }){ completed in
        
        for a in self.actions{
            a.button.removeFromSuperview()
        }
    }

    }
    
    
     func triggerAction(sender:UIButton){
        for a in actions{
            if sender == a.button{
                a.action()
            }
        }
    }
    
    
    private func rectForDirection(direction: Direction) -> (base: CGRect,sub: CGRect ){
        var base: CGRect
        var sub: CGRect
        switch(direction){
        case .east:
             base = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: maxSize, height: minSize)
             sub = expandButton!.bounds
        
        case .west:
             base = CGRect(x: self.frame.origin.x - maxSize + minSize, y: self.frame.origin.y, width: maxSize, height: minSize)
             let x = maxSize - minSize
             sub = CGRect(x: x, y: self.bounds.origin.y, width: minSize, height: minSize)
        
        case .south:
            base = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: minSize, height: maxSize)
            sub = expandButton!.bounds
        
        case .north:
            base = CGRect(x: self.frame.origin.x, y: self.frame.origin.y - maxSize + minSize, width: minSize, height: maxSize)
            let y = maxSize - minSize
            sub =  CGRect(x: self.bounds.origin.y, y: y, width: minSize, height: minSize)
        }
        return (base, sub)
    }
    
   private func panStatusChanged(){
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(callPanDelegate))
        
        
        if self.panable && self.expandButton!.gestureRecognizers == nil{
            self.expandButton!.addGestureRecognizer(panGesture)
        }
        if !panable{
            self.expandButton!.removeGestureRecognizer(panGesture)
        }
    }
    
    private func slideStatusChanged(){
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(expand))
        
        let slideGesture = UIPanGestureRecognizer(target: self, action: #selector(callSlideDelegate))
        
        if self.slideable{
            self.addGestureRecognizer(longPressGesture)
            self.addGestureRecognizer(slideGesture)
        }
        
    }
    
    // MARK: ExpandButton Editing Functions
    func setExpandButtonTitle(title:String?, font: UIFont?){
        if let title = title{
            self.expandButton?.setTitle(title, for: .normal)
        }
        
        
        if let font = font{
            expandButton?.titleLabel?.font = font
        }
    }
    
    func setExpandButtonColor(color: UIColor){
        expandButton?.backgroundColor = color
    }
    
    func setExpandButtonImage(image: UIImage){
        expandButton?.setImage(image, for: .normal)
        expandButton?.imageView?.contentMode = .scaleAspectFit
        expandButton?.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        
    }
    
    
    // MARK: Toolbar Action Editing Functions

    func removeButton(index: Int){
        self.contractActionButtons()
        self.actions.remove(at: index)
    }
    
    func setTitleForButtonAt(index: Int, title: String, font: UIFont?){
        
        let thisButton = self.actions[index].button
        thisButton.setTitle(title, for: .normal)
        if let font = font{
            thisButton.titleLabel?.font = font
        }
        
    }
    
    func setImageForButtonAt(index:Int, image:UIImage){
        self.actions[index].button.setImage(image, for: .normal)
        self.actions[index].button.imageView?.contentMode = .scaleAspectFit
    }
    
    func setColorsForActionAt(index: Int, color: UIColor){
        self.actions[index].button.backgroundColor = color
    }
    
    
    
    
    
    func callPanDelegate(){ // TODO: How do I modify the access level of this function if
        print("calling delegate")
        self.panDelegate?.moveToolbar(sender: self.expandButton!.gestureRecognizers![0] as! UIPanGestureRecognizer, source: self)
    }
    
    
    func callSlideDelegate(){
        
    
    }
}


enum Direction{
    case north
    case south
    case east
    case west
}

struct ToolbarAction {
    var button: ToolbarButton
    var action: () -> ()
    
    var image:UIImage?{
        didSet{
            self.button.setImage(image, for: .normal)
            self.button.imageView?.contentMode = .scaleAspectFit
        }
    }
    

    init(button:ToolbarButton, image: UIImage?, action: @escaping () -> ()){
        self.button = button
        self.action = action
        if let image = image{
            self.image = image
            self.button.imageView?.contentMode = .scaleAspectFit
        }
    }

}


protocol Pannable{
    func moveToolbar(sender: UIPanGestureRecognizer, source:UIView)
}

protocol Slideable{
    func triggerSlide(sender: UIPanGestureRecognizer, source: UIView)
}


// TODO: Eliminate redundancy

extension Pannable where Self: UIViewController{
    func moveToolbar(sender: UIPanGestureRecognizer, source: UIView){
        if sender.state == .began || sender.state == .changed {
            
            let translation = sender.translation(in: self.view)

            source.center = CGPoint(x: source.center.x + translation.x, y: source.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: self.view)
        }
    }
}

extension Pannable where Self: UIView{
    func moveToolbar(sender: UIPanGestureRecognizer, source: UIView){
        if sender.state == .began || sender.state == .changed {
            
            let translation = sender.translation(in: self)
            
            source.center = CGPoint(x: source.center.x + translation.x, y: source.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: self)
        }
    }
}



extension Slideable where Self: UIViewController{
    func triggerSlide(sender: UIPanGestureRecognizer, source: UIView){
        if sender.state == .began || sender.state == .changed{
            
//            let tranlsation = sender.
            
        }
    }
    
}


class ToolbarButton: UIButton {
    
    
    func setFont(font:UIFont){
        self.titleLabel?.font = font
    }
    
    func setBorder(width: CGFloat){
        self.layer.borderWidth = width
    }
    
    func setBorderColor(color: UIColor){
        self.layer.borderColor = color.cgColor
    }
    
}




