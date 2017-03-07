//
//  SeeImageController.swift
//  Locus
//
//  Created by Nabil K on 2017-02-11.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit

class SeeImageController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    

    
    var image: UIImage?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = self.image
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    @IBAction func backButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
