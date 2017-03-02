//
//  OverlayButtonView.swift
//  Locus
//
//  Created by Nabil K on 2017-03-01.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit

protocol OverlayButtonViewDelegate: class{
    
    func overlayButtonTriggered(type: overlayButtonType)
    
}

class OverlayButtonView: UIView {

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black
        self.layer.opacity = 0.7
        
        //set button frames
        let mapButtonFrame = CGRect(x: frame.width/6, y: frame.height, width: frame.width/3, height: frame.width/3)
        let editButtonFrame = CGRect(x: frame.width/2, y: frame.height, width: frame.width/3, height: frame.width/3)
        
        let mapButton = UIButton(frame: mapButtonFrame)
        let editButton = UIButton(frame: editButtonFrame)
        
        mapButton.layer.shadowRadius = 5
        mapButton.layer.shadowColor = UIColor.black.cgColor
        
        editButton.layer.shadowRadius = 5
        editButton.layer.shadowColor = UIColor.black.cgColor
        
        
        UIView.animate(withDuration: 3) {
            mapButton.center = CGPoint(x: mapButton.frame.origin.x, y: frame.height/CGFloat(2))
        }
        
        
        UIView.animate(withDuration: 3, delay: 1, animations: {
            
            editButton.center = CGPoint(x: editButton.frame.origin.x, y: frame.height/CGFloat(2))
            
        })
        
        
        
        func mapTapped(){
            
            
        }
        
        func editTapped(){
            
            
        }
        

        
        
        
        
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

enum overlayButtonType{
    
    case map
    case edit
    
}
