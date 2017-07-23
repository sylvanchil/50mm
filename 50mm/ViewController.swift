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
    @IBOutlet weak var capturePreview: UIView!
    
    @IBAction func captureImage(_ sender: UIButton) {
        cameraController.captureImage()
        
    }

    @IBOutlet weak var outputSetting: UIButton!
    @IBOutlet weak var focalLengthIndicator: UIButton!
    @IBOutlet weak var flashStatus: UIButton!
    @IBOutlet weak var frameLineview: UIView!
    
    
    @IBAction func outputSetting(_ sender: UIButton) {
        cameraController.nextSetting()
        outputSetting.setTitle(cameraController.currentSetting(), for: .normal)
        
    }
    @IBAction func changeFocalLength(_ sender: UIButton) {
        cameraController.nextFocalLength()
        focalLengthIndicator.setTitle(String(cameraController.currentFocalLength()), for: .normal)
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
    
    
    
    func addFrameLine(){
        self.frameLineview.layer.borderWidth = 4
        self.frameLineview.layer.borderColor = UIColor.orange.cgColor
        self.frameLineview.layer.opacity = 0.2
        
        self.frameLineview.layer.transform = CATransform3DMakeScale(0.85,0.85,0.85)
        //self.frameLineview.layer.transform = CATransform3DScale(frameLineview.layer.transform, 0.85,0.85,0.85)
        self.frameLineview.layer.transform = CATransform3DTranslate(frameLineview.layer.transform, -43.5, -33, 0)
        
        self.frameLineview.layer.transform = CATransform3DScale(frameLineview.layer.transform, 0.58,0.58,0.58)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cameraController.prepareCamera()
        cameraController.beginSession()
        cameraController.outputToUIView(to: capturePreview)
        addFrameLine()
        reloadUI()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        

    

    
}




