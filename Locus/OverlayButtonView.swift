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
    
    var buttonTapped: OverlayButtonType?
    
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        setupButtons()
        
        //set button frames

        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        self.addGestureRecognizer(tap)
        
    }
    
    
    func setupButtons() {
        
        let westButtonFrame = CGRect(x: frame.width*0.07, y: frame.height, width: frame.width/3, height: frame.width/3)
        let eastButtonFrame = CGRect(x: frame.midX + frame.width*0.1, y: frame.height, width: frame.width/3, height: frame.width/3)
        
        self.westButton = UIButton(frame: westButtonFrame)
        self.eastButton = UIButton(frame: eastButtonFrame)
        
        westButton.layer.shadowRadius = 5
        westButton.layer.shadowColor = UIColor.black.cgColor
        westButton.layer.cornerRadius = westButton.frame.width/2
        westButton.backgroundColor = UIColor.green
        
        westButton.addTarget(self, action: #selector(westTapped), for: .allEvents)
        
        eastButton.layer.shadowRadius = 5
        eastButton.layer.shadowColor = UIColor.black.cgColor
        eastButton.layer.cornerRadius = eastButton.frame.width/2
        eastButton.backgroundColor = UIColor.red
        
        self.addSubview(westButton)
        self.addSubview(eastButton)
        
        
        westButton.addTarget(self, action: #selector(westTapped), for: .allEvents)
        
        eastButton.addTarget(self, action: #selector(eastTapped), for: .allEvents)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func animateButtons(){
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, animations: {
            self.westButton.center = CGPoint(x: self.westButton.frame.midX, y: self.frame.height/CGFloat(2))
            
        })
        
        
        UIView.animate(withDuration: 1, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, animations: {
            self.eastButton.center = CGPoint(x: self.eastButton.frame.midX, y: self.frame.height/CGFloat(2))
            
        })
    }
        
    
    
    func dismiss(){
        removeFromSuperview()
    }
    
    
    func westTapped(){
        if let delegate = delegate{
            delegate.overlayButtonTriggered(type: .west, indexPath: self.indexPath)
        }
    }
    
    func eastTapped(){
        
        if let delegate = delegate{
            delegate.overlayButtonTriggered(type: .east, indexPath: self.indexPath)
        }
    }
   
}

enum OverlayButtonType{
    
    case west
    case east
    
}
