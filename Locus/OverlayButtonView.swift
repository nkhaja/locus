//
//  OverlayButtonView.swift
//  Locus
//
//  Created by Nabil K on 2017-03-01.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit

protocol OverlayButtonViewDelegate: class{
    
    func overlayButtonTriggered(type: OverlayButtonType, indexPath: IndexPath?)
    
}


class OverlayButtonView: UIView {
    
    weak var delegate: OverlayButtonViewDelegate?
    var indexPath: IndexPath?
    
    var eastButton: UIButton!
    var westButton: UIButton!
    
    var northButton: UIButton!
    var southButton: UIButton!
    
    let buttons: [UIButton] = []
    
    var buttonTapped: OverlayButtonType?
    
    var proportion: CGFloat = 3
    var padding: CGFloat = 4
    
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        setupButtons()
        
        //set button frames

        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        self.addGestureRecognizer(tap)
        
    }
    
    
    func setupButtons() {
        
        let westButtonFrame = CGRect(x: frame.width*0.07, y: frame.height, width: frame.width/proportion, height: frame.width/proportion)
        let eastButtonFrame = CGRect(x: frame.midX + frame.width*0.1, y: frame.height, width: frame.width/proportion, height: frame.width/proportion)
        
        // southButtonFrame is identical
        let northButtonFrame = CGRect(x: frame.midX - frame.width/(proportion*2), y: frame.height, width: frame.width/proportion, height: frame.width/proportion)
        
 
        
        self.westButton = UIButton(frame: westButtonFrame)
        self.eastButton = UIButton(frame: eastButtonFrame)
        self.northButton = UIButton(frame: northButtonFrame)
        self.southButton = UIButton(frame: northButtonFrame)
        
        
        let buttons : [UIButton] = [eastButton, westButton, northButton, southButton]
        let colors : [UIColor] = [.blue, .red, .green, .purple]
        
        for i in 0..<buttons.count{
            
            let button = buttons[i]
            
            button.layer.shadowRadius = 5
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.cornerRadius = westButton.frame.width/2
            button.backgroundColor = colors[i]
            self.addSubview(button)
        }

        
        
        westButton.addTarget(self, action: #selector(westTapped), for: .allEvents)
        eastButton.addTarget(self, action: #selector(eastTapped), for: .allEvents)
        
        northButton.addTarget(self, action: #selector(northTapped), for: .allEvents)
        southButton.addTarget(self, action: #selector(southTapped), for: .allEvents)

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func animateButtons(){
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, animations: {
            self.westButton.center = CGPoint(x: self.westButton.frame.midX, y: self.frame.height/CGFloat(2))
            
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, animations: {
            self.northButton.center = CGPoint(x: self.frame.width/2, y: self.frame.midY - self.northButton.frame.height + self.padding)
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, animations: {
            self.eastButton.center = CGPoint(x: self.eastButton.frame.midX, y: self.frame.height/CGFloat(2))
            
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, animations: {
            self.southButton.center = CGPoint(x: self.frame.width/2, y: self.frame.midY + self.southButton.frame.height - self.padding)
        })
        
    }
        
    
    
    func dismiss(){
        removeFromSuperview()
    }
    
    
    func westTapped(){
        if let delegate = delegate{
            delegate.overlayButtonTriggered(type: .west, indexPath: self.indexPath)
            self.dismiss()
        }
    }
    
    func eastTapped(){
        
        if let delegate = delegate{
            delegate.overlayButtonTriggered(type: .east, indexPath: self.indexPath)
            self.dismiss()
        }
    }
    
    
    func northTapped(){
        delegate?.overlayButtonTriggered(type: .north, indexPath: self.indexPath)
    }
    
    func southTapped(){
        delegate?.overlayButtonTriggered(type: .south, indexPath: self.indexPath)
    }
   
}

enum OverlayButtonType{
    case north
    case south
    case east
    case west
    
}
