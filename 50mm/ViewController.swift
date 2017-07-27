//
//  ViewController.swift
//  50mm
//
//  Created by Kevin on 7/20/17.
//  Copyright © 2017 cungjau. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController {
    
    var cameraController = CameraController()
    var reviewing = false
    var touchOriginPosition = CGPoint(x:0,y:0)
    var originLensPosition : Float = 0.0
    var originExposureBias : Float = 0.0
    
    @IBAction func captureImage(_ sender: UIButton) {
        cameraController.captureImage()
        frameLineview.layer.borderColor = UIColor.white.cgColor
        frameLineview.layer.borderWidth = 5
        frameLineview.layer.opacity = 0.4
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(DispatchTime.now().uptimeNanoseconds) + UInt64(2000000)), execute: {
            
            self.frameLineview.layer.borderColor = UIColor.orange.cgColor
            
            self.frameLineview.layer.borderWidth = CGFloat(3.0)
            self.frameLineview.layer.opacity = 0.3
            
        })
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.cameraController.updateCachePhotos()
            self.updateThumbNail()
            self.updateReviewThumbs()
            
        })
        
        
        
    }
    
    
    @IBOutlet weak var caliperView: UIImageView!

    @IBOutlet weak var DOFBarView: UIImageView!
    @IBOutlet weak var focusConfirm: UIView!
    @IBOutlet weak var ImageReviewThumbStack: UIStackView!
    @IBOutlet weak var outputSetting: UIButton!
    @IBOutlet weak var focalLengthIndicator: UIButton!
    @IBOutlet weak var flashStatus: UIButton!
    @IBOutlet weak var frameLineview: UIView!
    @IBOutlet weak var capturePreview: UIView!
    @IBOutlet weak var reviewThumbView: UIImageView!
    
    @IBOutlet weak var reviewLargeView: UIImageView!
    
    @IBAction func outputSetting(_ sender: UIButton) {
        cameraController.nextSetting()
        outputSetting.setTitle(cameraController.currentSetting(), for: .normal)
        
        
    }
    @IBAction func changeFocalLength(_ sender: UIButton) {
        cameraController.nextFocalLength()
        focalLengthIndicator.setTitle(String(cameraController.currentFocalLength()), for: .normal)
        reloadFrameLine()
        
    }
    @IBAction func toggleFlash(_ sender: Any) {
        cameraController.toggleFlash()
        
        if(cameraController.usingFlash()){
            flashStatus.setImage(#imageLiteral(resourceName: "withFlash"), for: .normal)
        }else{
            flashStatus.setImage(#imageLiteral(resourceName: "noflash"), for: .normal)
        }
        
    }
    func reloadUI(){
        outputSetting.setTitle(cameraController.currentSetting(), for: .normal)
        focalLengthIndicator.setTitle(String(cameraController.currentFocalLength()), for: .normal)
        
        if(cameraController.usingFlash()){
            flashStatus.setImage(#imageLiteral(resourceName: "withFlash"), for: .normal)
        }else{
            flashStatus.setImage(#imageLiteral(resourceName: "noflash"), for: .normal)
        }

    }
    
    
    func reloadFrameLine(){
        if(abs(cameraController.getCroppingRatio()-1) < 0.01){
            self.frameLineview.layer.opacity = 0
        }else{
            
            self.frameLineview.layer.opacity = 0.3
            let ratio = cameraController.getCroppingRatio()
            self.frameLineview.layer.borderWidth = CGFloat(3.0/ratio)
            
            self.frameLineview.layer.transform = CATransform3DMakeScale(CGFloat(ratio) ,CGFloat(ratio) ,CGFloat(ratio))
            
        }
    }
    
    func addFrameLine(){
        self.frameLineview.layer.borderWidth = 3
        self.frameLineview.layer.borderColor = UIColor.orange.cgColor
        reloadFrameLine()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cameraController.prepareCamera()
        cameraController.beginSession()
        cameraController.outputToUIView(to: capturePreview)
        
        addFrameLine()
        reloadUI()
        
        ImageReviewThumbStack.layer.opacity = 0
        focusConfirm.layer.borderWidth = 2
        focusConfirm.layer.borderColor = UIColor.green.cgColor
        focusConfirm.layer.opacity = 0
        
        updateThumbNail()
        
        print(caliperView.layer.position)
        print(DOFBarView.layer.position)
        //DOFBarOriginPosition = DOFBarView.layer.position
        // Do any additional setup after loading the view, typically from a nib.  
        addObserver(self, forKeyPath: #keyPath(cameraController.captureDevice.lensPosition), options:[.new, .old], context: nil)
        addObserver(self, forKeyPath: #keyPath(cameraController.captureDevice.isAdjustingFocus), options: [.new, .old], context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //if (keyPath == #keyPath(cameraController.captureDevice.lensPosition) && cameraController.captureDevice.focusMode == AVCaptureFocusMode.autoFocus){
        if (keyPath == #keyPath(cameraController.captureDevice.lensPosition)){
                
            // Update Time Label
            //print(captureDevice.lensPosition)
           // DOFBarView.layer.position.y = DOFBarOriginPosition.y + CGFloat(Float(DOFBarView.layer.bounds.height) * (cameraController.captureDevice.lensPosition-0.5))
            
            DOFBarView.layer.transform = CATransform3DMakeTranslation(0,  CGFloat(Float(DOFBarView.layer.bounds.height) * (cameraController.captureDevice.lensPosition-0.5)), 0)

            //print(DOFBarView.layer.position.y - DOFBarOriginPosition.y)
            
        }else if (keyPath == #keyPath(cameraController.captureDevice.isAdjustingFocus )){
            if(cameraController.captureDevice.isAdjustingFocus == false){
                focusConfirm.layer.opacity = 0
            }
        }
    }



    func updateThumbNail(){
        reviewThumbView.image = cameraController.recentImages?.first
    
    }
    
    func updateReviewThumbs(){
        var iter = 5
        for views in ImageReviewThumbStack.subviews{
            (views as! UIImageView).image = cameraController.recentImages?[iter]
            iter = iter - 1
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //cameraController.changeLensPosition(to:1.0)
        
        
        //review
        if(reviewThumbView.bounds.contains((touches.first?.location(in: reviewThumbView))!)){
            
            self.updateThumbNail()
            self.updateReviewThumbs()
            self.reviewLargeView.image = reviewThumbView.image
            
            ImageReviewThumbStack.layer.opacity = 1
            reviewing = true
        }
        //manual focus
        else if(DOFBarView.bounds.contains((touches.first?.location(in: DOFBarView))!)){
            //begin manual focus
            touchOriginPosition = (touches.first?.location(in: capturePreview))!
            originLensPosition = cameraController.captureDevice.lensPosition
        }
        // touch focus
        else if(capturePreview.bounds.contains((touches.first?.location(in: capturePreview))!)){
            touchOriginPosition = (touches.first?.location(in: capturePreview))!
            originExposureBias = cameraController.captureDevice.exposureTargetBias
            
            
            let touchPoint = touches.first!
            let screenSize = capturePreview.bounds.size
            
            let focusPoint = CGPoint(x: touchPoint.location(in: capturePreview).x / screenSize.width,
                                     y: touchPoint.location(in: capturePreview).y / screenSize.height)
   
            let touchLocation = touchPoint.location(in: capturePreview)
            
            var x = touchLocation.x
            x = x < 25 ? 25 : x
            x = x > (capturePreview.layer.bounds.size.width - 25) ? (capturePreview.layer.bounds.size.width - 25) : x
            var y = touchLocation.y
            y = y < 19 ? 19 : y
            y = y > (capturePreview.layer.bounds.size.height - 19) ? (capturePreview.layer.bounds.size.height - 19) : y
            
            focusConfirm.layer.position = CGPoint(x: x, y: y)
            focusConfirm.layer.opacity = 0.4
            cameraController.focus(on: focusPoint)

        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let imageViews = ImageReviewThumbStack.subviews
        
        if(reviewing){
            for imageThumb in imageViews{
                if(imageThumb.bounds.contains((touches.first?.location(in: imageThumb))!)){
                    reviewLargeView.layer.opacity = 1.0
                    
                    imageThumb.layer.opacity = 1
                    imageThumb.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1.1)
                    imageThumb.layer.borderColor = UIColor.white.cgColor
                    imageThumb.layer.borderWidth = 2
                    reviewLargeView.image = (imageThumb as! UIImageView).image
                }
                else{
                    imageThumb.layer.opacity = 0.8
                    imageThumb.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    imageThumb.layer.borderWidth = 0
                }
            }
            if(reviewThumbView.bounds.contains((touches.first?.location(in: reviewThumbView))!)){
                reviewLargeView.layer.opacity = 1.0
                self.reviewLargeView.image = reviewThumbView.image
            }
        }
        //else
        if(DOFBarView.bounds.contains((touches.first?.location(in: DOFBarView))!)){
            //set lens position
            //
            if(cameraController.captureDevice.isLockingFocusWithCustomLensPositionSupported){
                let newLocation = touches.first?.location(in: capturePreview)
                var newLensPosition = originLensPosition + Float(((newLocation?.y)! - touchOriginPosition.y) / DOFBarView.layer.bounds.height)
                
                newLensPosition = newLensPosition > 1.0 ? 1.0 : newLensPosition
                newLensPosition = newLensPosition < 0 ? 0 : newLensPosition
                do{
                    try cameraController.captureDevice.lockForConfiguration()
                }catch{
                
                }
                cameraController.captureDevice.setFocusModeLockedWithLensPosition(newLensPosition, completionHandler: nil)
                cameraController.captureDevice.unlockForConfiguration()
            }
            
        }else{
            let newLocation = touches.first?.location(in: capturePreview)
            let newOffset =  ((newLocation?.y)! - touchOriginPosition.y)/capturePreview.layer.bounds.height * -2.0
            
            do{
                try cameraController.captureDevice.lockForConfiguration()
            }catch{
                
            }
            
            cameraController.captureDevice.setExposureTargetBias(Float(newOffset), completionHandler: nil)

            cameraController.captureDevice.unlockForConfiguration()
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            reviewLargeView.layer.opacity = 0
            ImageReviewThumbStack.layer.opacity = 0
            reviewing = false
    }
}




