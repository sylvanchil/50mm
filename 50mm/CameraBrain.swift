//
//  CameraBrain.swift
//  50mm
//
//  Created by Kevin on 7/21/17.
//  Copyright © 2017 cungjau. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Photos

class CameraBrain:NSObject{
    //focal length
    //flash setting
    //raw, jpeg, raw+ jpeg
    // exif info
    //image orientation
    //capture success feedback
    //shorter launch time
    //crop rate base on device

    //omit prompt
    
    let lengthOfFilm = 36.0
    let widthOfFilm = 24.0
    
    private var defaultFocalLength = 0
    
    //origin 35 50
    private var focalLengthIndex = 0
    //on or off
    private var flashMode = false
    //raw jpeg raw+jpeg
    private var captureModeIndex = 0

    private var deviceName :String?
    
    public func currentFocalLength()->Int{
        switch focalLengthIndex{
        case 0:
            return defaultFocalLength
        case 1:
            return 35
        case 2:
            return 50
        default:
            return 0
        }
    }
    
    public func setDefaultFocalLength(using focalLength:Int){
        defaultFocalLength = focalLength
    }
    public func getDefaultFocalLength()->Int{
        return defaultFocalLength
    }
    
    public func toggleFlash(){
        flashMode = !flashMode
    }
    public func flashIsOn()->Bool{
        return flashMode
    }
    public func currentOutputSetting()->String{
        switch captureModeIndex {
        case 0:
            return String(" RAW")
        case 1:
            return String("JPEG")
        case 2:
            return String(" RAW\n   +\nJPEG")
        default:
            return String("")
        }
    }
    
    public func croppingRatio()->Double{
        let defaultAOV = angleOfView(of: Double(defaultFocalLength))
        
        let currAOV = angleOfView(of: Double(self.currentFocalLength()))
        
        return tan( currAOV.angleH/2 * Double.pi / 180 ) / tan( defaultAOV.angleH/2 * Double.pi / 180)
    }
    
    public func nextOutputSetting(){
        captureModeIndex = (captureModeIndex+1)%3
    }
    
    public func nextFocalLength(){
        focalLengthIndex = (focalLengthIndex+1)%3
    }
    
    
    private func angleOfView(of focalLength: Double)->angleOfViews{
        return angleOfViews(angleH: 2*atan(lengthOfFilm/2/focalLength)/Double.pi*180.0,
                     angleV: 2*atan(widthOfFilm/2/focalLength)/Double.pi*180.0)
    }
    
}

struct angleOfViews{
    let angleH, angleV : Double
    init(angleH:Double, angleV:Double){
        self.angleH = angleH
        self.angleV = angleV
    }
}

extension CameraBrain : AVCapturePhotoCaptureDelegate{
    public func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?){
        
        if let photoSampleBuffer = photoSampleBuffer {
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            let image = UIImage(data: photoData!)
            
            let finalImage = image?.crop(rect: CGRect(x: 848, y: 636, width: 2336, height: 1752))
            //let finalImage2 = finalImage?.fixImageOrientation()
            UIImageWriteToSavedPhotosAlbum(finalImage!, nil, nil, nil)
        }
        
    }
    
}


extension UIImage {
    func crop( rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}

