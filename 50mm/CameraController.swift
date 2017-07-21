//
//  CameraController.swift
//  50mm
//
//  Created by Kevin on 7/21/17.
//  Copyright © 2017 cungjau. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class CameraController:NSObject{
    private var captureSession = AVCaptureSession()
    private var viewFinderLayer : AVCaptureVideoPreviewLayer?
    private var captureDevice :AVCaptureDevice!
    private var capturePhotoOutput = AVCapturePhotoOutput()
    
    private var photoCaptureProcessor = PhotoCaptureProcessor()
    
    func prepareCamera(){
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        if let availiableDevices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .back).devices{
            captureDevice = availiableDevices.first
        }
    }
    
    func beginSession(){
        //it could be problem, so use do try, (camera permission)
        do{
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
            
        }catch {
            print(error.localizedDescription)
        }
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings=[(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCMPixelFormat_32BGRA)]
        dataOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(dataOutput){
            captureSession.addOutput(dataOutput)
        }
        
        if captureSession.canAddOutput(capturePhotoOutput){
            captureSession.addOutput(capturePhotoOutput)
        }
        
        captureSession.commitConfiguration()
        captureSession.startRunning()
        
    }
    
    func outputToUIView(to UIViewLayer : UIView){
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession){
            //messy shit here 
            self.viewFinderLayer = previewLayer
            self.viewFinderLayer?.frame = UIViewLayer.bounds
            self.viewFinderLayer?.transform = CATransform3DMakeRotation(CGFloat(-90.0 / 180.0 * .pi), 0.0, 0.0, 1.0)
            self.viewFinderLayer?.transform = CATransform3DScale((self.viewFinderLayer?.transform)!, 1.13,1.13,1.13)
            self.viewFinderLayer?.transform = CATransform3DTranslate((self.viewFinderLayer?.transform)!, 24, -33, 0)
            
            UIViewLayer.layer.addSublayer(self.viewFinderLayer!)
        }

    }
    
    public func toggleFlash(){
        //should be in camerabrain
        
        if captureDevice!.hasFlash{
            do{
                try captureDevice!.lockForConfiguration()
                captureDevice!.torchMode = captureDevice.isTorchActive ? AVCaptureTorchMode.off: AVCaptureTorchMode.on
                
                captureDevice!.unlockForConfiguration()
            }catch{
                
            }
        }
        
    }
    public func captureImage(){
        let photoSetting:AVCapturePhotoSettings =  AVCapturePhotoSettings()
        photoSetting.flashMode = captureDevice.isTorchActive ? AVCaptureFlashMode.on : AVCaptureFlashMode.off
        
        capturePhotoOutput.capturePhoto(with: photoSetting, delegate: photoCaptureProcessor )
    }
    
    
}
