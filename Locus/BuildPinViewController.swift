//
//  BuildPinViewController.swift
//  Locus
//
//  Created by Nabil K on 2017-01-03.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit

class BuildPinViewController: UIViewController {

    
    @IBOutlet weak var scrollView: UIScrollView!

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)

        // Do any additional setup after loading the view.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func adjustInsetForKeyboardShow(show: Bool, notification: Notification) {
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        let adjustmentHeight = (keyboardFrame.height + 20) * (show ? 1 : -1)
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
    
    func keyboardWillShow(notification: Notification) {
        adjustInsetForKeyboardShow(show: true, notification: notification)
    }
    
    func keyboardWillHide(notification: Notification) {
        adjustInsetForKeyboardShow(show: false, notification: notification)
    }


    
    
}


//Handle keyboard

extension BuildPinViewController {
    

 
    
//    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
//        return changePicBtn
//    }
//    
//    func scrollViewDidZoom(scrollView: UIScrollView) {
//        updateConstraintsForSize(size: view.bounds.size)
//    }
//    
//    
//    private func updateMinZoomScaleForSize(size: CGSize) {
//        let widthScale = size.width / changePicBtn.bounds.width
//        let heightScale = size.height / changePicBtn.bounds.height
//        let minScale = min(widthScale, heightScale)
//        
//        scrollView.minimumZoomScale = minScale
//        scrollView.zoomScale = minScale
//    }
//    
//    private func updateConstraintsForSize(size: CGSize) {
//        
//        let yOffset = max(0, (size.height - changePicBtn.frame.height) / 2)
//        imageBtnTopConstraint.constant = yOffset
//        imageBtnBottomConstraint.constant = yOffset
//        
//        let xOffset = max(0, (size.width - changePicBtn.frame.width) / 2)
//        imageBtnLeadingConstraint.constant = xOffset
//        imageBtnTrailingConstraint.constant = xOffset
//        
//        view.layoutIfNeeded()
//    }
    
}

