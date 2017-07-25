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
    
    @IBAction func captureImage(_ sender: UIButton) {
        cameraController.captureImage()
        frameLineview.layer.borderColor = UIColor.white.cgColor
        frameLineview.layer.borderWidth = 5
        frameLineview.layer.opacity = 0.4
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(DispatchTime.now().uptimeNanoseconds) + UInt64(1000000)), execute: {
            
            self.frameLineview.layer.borderColor = UIColor.orange.cgColor
            
            self.frameLineview.layer.borderWidth = CGFloat(3.0)
            self.frameLineview.layer.opacity = 0.3
            
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.putLastPhotoAtThumbnail()
        })
        
    }

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
    
    
    
    func putLastPhotoAtThumbnail(){
        
        let imgManager = PHImageManager.default()
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        if fetchResult.count > 0{
            let theLastImageAssest = fetchResult.lastObject
            let options = PHImageRequestOptions()
            options.version = .current
            imgManager.requestImage(for: theLastImageAssest!, targetSize: reviewThumbView.bounds.size, contentMode: .aspectFit, options: options, resultHandler: {
                result , _ in
                self.reviewThumbView.image = result!
            })
        }
        
    }
    
    func putLastPhotoAtReview(){
        
        let imgManager = PHImageManager.default()
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        if fetchResult.count > 0{
            let theLastImageAssest = fetchResult.lastObject
            let options = PHImageRequestOptions()
            options.version = .current
            imgManager.requestImage(for: theLastImageAssest!, targetSize: reviewLargeView.bounds.size, contentMode: .aspectFit, options: options, resultHandler: {
                result , _ in
                    self.reviewLargeView.image = result!
                })
        }
        
        reviewLargeView.layer.opacity = 1
 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cameraController.prepareCamera()
        cameraController.beginSession()
        cameraController.outputToUIView(to: capturePreview)
        
        addFrameLine()
        reloadUI()
        
        putLastPhotoAtThumbnail()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        //print(touches.first?.location(in: reviewThumbView))
        if(reviewThumbView.bounds.contains((touches.first?.location(in: reviewThumbView))!)){
            putLastPhotoAtReview()
        }
        
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            reviewLargeView.layer.opacity = 0
    }
}




