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
    
    
    //raw, jpeg, raw+ jpeg
    
    //capture success feedback
    //shorter launch time
    //touch focus
    
    
    let lengthOfFilm = 36.0
    let widthOfFilm = 24.0
    
    private var defaultFocalLength = 0
    //origin 35 50
    private var focalLengthIndex = 2
    //on or off
    private var flashMode = false
    //jpeg raw+jpeg
    private var captureModeIndex = 0

    private var deviceName :String?
    
    var photoSampleBuffer: CMSampleBuffer?
    var previewPhotoSampleBuffer: CMSampleBuffer?
    var rawSampleBuffer: CMSampleBuffer?
    var rawPreviewPhotoSampleBuffer: CMSampleBuffer?
    
    
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
    
    
    public func currentOutputSettingIndex()->Int{
        return captureModeIndex
    }

   /*
    
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
 
 */
    
    
    
    public func croppingRatio()->Double{
        let defaultAOV = angleOfView(of: Double(defaultFocalLength))
        
        let currAOV = angleOfView(of: Double(self.currentFocalLength()))
        
        return tan( currAOV.angleH/2 * Double.pi / 180 ) / tan( defaultAOV.angleH/2 * Double.pi / 180)
    }
    
    public func nextOutputSetting(){
        if deviceName == nil{
            deviceName = UIDevice.current.modelName
        }
        
        if(deviceName == "iPhone 6s"
            || deviceName == "iPhone 6s Plus"
            || deviceName == "iPhone 7"
            || deviceName == "iPhone 7 Plus"
            || deviceName == "iPhone SE"){
            captureModeIndex = (captureModeIndex+1)%2
        }
    }
    
    public func nextFocalLength(){
        focalLengthIndex = (focalLengthIndex+1)%3
    }
    
    
    private func angleOfView(of focalLength: Double)->angleOfViews{
        return angleOfViews(angleH: 2*atan(lengthOfFilm/2/focalLength)/Double.pi*180.0,
                     angleV: 2*atan(widthOfFilm/2/focalLength)/Double.pi*180.0)
    }
    
    func checkPhotoLibraryAuthorization(_ completionHandler: @escaping ((_ authorized: Bool) -> Void)) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            // The user has previously granted access to the photo library.
            completionHandler(true)
            
        case .notDetermined:
            // The user has not yet been presented with the option to grant photo library access so request access.
            PHPhotoLibrary.requestAuthorization({ status in
                completionHandler((status == .authorized))
            })
            
        case .denied:
            // The user has previously denied access.
            completionHandler(false)
            
        case .restricted:
            // The user doesn't have the authority to request access e.g. parental restriction.
            completionHandler(false)
        }
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
            
            let originWidth = Double((image?.cgImage?.width)!)
            let originHeight = Double((image?.cgImage?.height)!)
            
            let width = originWidth * croppingRatio()
            let height = originHeight * croppingRatio()
            
            var finalImage = image?.crop(rect: CGRect(x: originWidth/2 - width/2 , y: originHeight/2 - height/2
                , width: width, height: height))
 
            finalImage = UIImage(cgImage: (finalImage?.cgImage)!, scale: (finalImage?.scale)!, orientation: UIImageOrientation.up)
            UIImageWriteToSavedPhotosAlbum(finalImage!, nil, nil, nil)
            
        }
        
        guard error == nil, let photoSampleBuffer = photoSampleBuffer else {
            print("Error capturing photo:\(String(describing: error))")
            return
        }
        
        self.photoSampleBuffer = photoSampleBuffer
        self.previewPhotoSampleBuffer = previewPhotoSampleBuffer
        
        print("jpeg chill")
        
    }
    
    public func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingRawPhotoSampleBuffer rawSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        /*
        
        if let rawSampleBuffer = rawSampleBuffer{
            let dngData = AVCapturePhotoOutput.dngPhotoDataRepresentation(forRawSampleBuffer: rawSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            
            let dngFileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(resolvedSettings.uniqueID).dng")!
            
            do {
                try dngData?.write(to: dngFileURL, options: [])
            } catch _ as NSError {
                print("Unable to write DNG file.")
                
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                
                let creationRequest = PHAssetCreationRequest.forAsset()
                let creationOptions = PHAssetResourceCreationOptions()
                creationOptions.shouldMoveFile = true
                // creationRequest.addResource(with: .photo, data: jpegData, options: nil)
                creationRequest.addResource(with:PHAssetResourceType.alternatePhoto, fileURL: dngFileURL, options: creationOptions)
                
            }, completionHandler: { (success, error) -> Void in
                print("Finished deleting asset. %@", (success ? "Success" : (error ?? "no" as? Error)!))
                return
            })
            
        }
 */
        
        guard error == nil, let rawSampleBuffer = rawSampleBuffer else {
            print("Error capturing RAW photo:\(String(describing: error))")
            return
        }
        
        self.rawSampleBuffer = rawSampleBuffer
        self.rawPreviewPhotoSampleBuffer = previewPhotoSampleBuffer
        
        print("raw chill")
    }
    
    
    
    func capture(_ captureOutput: AVCapturePhotoOutput,
                 didFinishCaptureForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings,
                 error: Error?){
        print("finish chill")
    
        if let rawSampleBuffer = self.rawSampleBuffer, let photoSampleBuffer = self.photoSampleBuffer {
            
            saveRAWPlusJPEGPhotoLibrary(rawSampleBuffer,
                                        rawPreviewSampleBuffer: self.rawPreviewPhotoSampleBuffer,
                photoSampleBuffer: photoSampleBuffer,
                previewSampleBuffer: self.previewPhotoSampleBuffer,
                completionHandler: { success, error in
                    
                    if success {
                        print("Added RAW+JPEG photo to library.")
                    } else {
                        print("Error adding RAW+JPEG photo to library: \(String(describing: error))")
                    }
            })
        }

    }
    
    
    func saveRAWPlusJPEGPhotoLibrary(_ rawSampleBuffer: CMSampleBuffer,
                                     rawPreviewSampleBuffer: CMSampleBuffer?,
                                     photoSampleBuffer: CMSampleBuffer,
                                     previewSampleBuffer: CMSampleBuffer?,
                                     completionHandler: ((_ success: Bool, _ error: Error?) -> Void)?) {
        self.checkPhotoLibraryAuthorization({ authorized in
            guard authorized else {
                print("Permission to access photo library denied.")
                completionHandler?(false, nil)
                return
            }
            
            guard let jpegData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(
                forJPEGSampleBuffer: photoSampleBuffer,
                previewPhotoSampleBuffer: previewSampleBuffer)
                else {
                    print("Unable to create JPEG data.")
                    completionHandler?(false, nil)
                    return
            }
            
            guard let dngData = AVCapturePhotoOutput.dngPhotoDataRepresentation(
                forRawSampleBuffer: rawSampleBuffer,
                previewPhotoSampleBuffer: rawPreviewSampleBuffer)
                else {
                    print("Unable to create DNG data.")
                    completionHandler?(false, nil)
                    return
            }
            
            //let dngFileURL = self.makeUniqueTempFileURL(typeExtension: "dng")
            
            let dngFileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(UUID().uuidString).dng")!
            
            
            
            
            do {
                try dngData.write(to: dngFileURL, options: [])
            } catch let error as NSError {
                print("Unable to write DNG file.")
                completionHandler?(false, error)
                return
            }
            
            PHPhotoLibrary.shared().performChanges( {
                let creationRequest = PHAssetCreationRequest.forAsset()
                let creationOptions = PHAssetResourceCreationOptions()
                creationOptions.shouldMoveFile = true
                creationRequest.addResource(with: .photo, data: jpegData, options: nil)
                creationRequest.addResource(with: .alternatePhoto, fileURL: dngFileURL, options: creationOptions)
            }, completionHandler: completionHandler)
        })
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingRawPhoto rawSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?){
        print("just chill1")
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?,
                     previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?){
        print("just chill2")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
                     error: Error?){
        print("just chill3")
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



