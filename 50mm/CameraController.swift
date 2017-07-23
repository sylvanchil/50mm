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
    
    private var frameLineView: UIView?
    
    private var frameLineShapeLayer : CAShapeLayer?
    
    //private var photoCaptureProcessor = PhotoCaptureProcessor()
    private var cameraBrain = CameraBrain()
    
    func prepareCamera(){
       // cameraBrain.printDeviceName()
        cameraBrain.setDefaultFocalLength(using: self.defaultFocalLengthByDevice())
        
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
            self.viewFinderLayer?.transform = CATransform3DScale((self.viewFinderLayer?.transform)!, 1.14,1.14,1.14)
            self.viewFinderLayer?.transform = CATransform3DTranslate((self.viewFinderLayer?.transform)!, 24, -33, 0)
            
            
            UIViewLayer.layer.insertSublayer(self.viewFinderLayer!, at:0)
        }
    }
    
    public func toggleFlash(){

        cameraBrain.toggleFlash()
        
    }
    
    public func usingFlash()->Bool{
        return cameraBrain.flashIsOn() ? true : false
        
    }
    
    public func captureImage(){
        let photoSetting:AVCapturePhotoSettings =  AVCapturePhotoSettings()
        photoSetting.flashMode = captureDevice.isTorchActive ? AVCaptureFlashMode.on : AVCaptureFlashMode.off
        
        capturePhotoOutput.capturePhoto(with: photoSetting, delegate: cameraBrain )
    }
    
    public func nextFocalLength(){
        cameraBrain.nextFocalLength()
    }
    
    public func currentFocalLength()->Int{
        return cameraBrain.currentFocalLength()
    }
    
    public func nextSetting(){
        cameraBrain.nextOutputSetting()
        
    }
    public func currentSetting()->String{
        return cameraBrain.currentOutputSetting()
        
    }
    
    public func getCroppingRatio()->Double{
        return cameraBrain.croppingRatio()
    }
    

    private func defaultFocalLengthByDevice()->Int{
        let modelName = UIDevice.current.modelName
        
        switch modelName {
        case "iPhone 5", "iPhone 5c": return 33
        case "iPhone 5s": return 30
        case "iPhone 6","iPhone 6 Plus","iPhone 6s","iPhone 6s Plus","iPhone 7","iPhone SE": return 29
            
        case "iPhone 7 Plus" : return 28
        default:
            return 0
        }
    }
}


public extension UIDevice {
    

    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}

