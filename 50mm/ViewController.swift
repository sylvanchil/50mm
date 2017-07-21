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

    @IBAction func toggleFlash(_ sender: Any) {
        cameraController.toggleFlash()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cameraController.prepareCamera()
        cameraController.beginSession()
        cameraController.outputToUIView(to: capturePreview)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        

    

    
}




