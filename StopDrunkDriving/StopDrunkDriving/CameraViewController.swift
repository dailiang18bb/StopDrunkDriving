//
//  CameraViewController.swift
//  StopDrunkDriving
//
//  Created by charles on 10/24/18.
//  Copyright © 2018 liang. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession = AVCaptureSession()
    var frontCamera : AVCaptureDevice?
    
    var videoOutput = AVCaptureVideoDataOutput()
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    var cameraOrientation: UIDeviceOrientation?

    
//    var fileOutput : AVCaptureMovieFileOutput! //change the orientation to landscape


    override func viewDidLoad() {
        super.viewDidLoad()

        // Start the camera
        // **********************
        // input
        //    |
        //   \/
        // captureSession
        //    |
        //   \/
        // output
        // ************************
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    
    
    func setupCaptureSession(){
        //Set the capture preset
        captureSession.sessionPreset = AVCaptureSession.Preset.medium
        //captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice(){
        frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
    }
    
    func setupInputOutput(){
        do{
            let captureDeviceInput = try AVCaptureDeviceInput(device: frontCamera!)
            captureSession.addInput(captureDeviceInput)
            
            // Output
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: NSNumber(value: kCVPixelFormatType_32BGRA)]
            videoOutput.alwaysDiscardsLateVideoFrames = true
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            captureSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.liang")
            videoOutput.setSampleBufferDelegate(self, queue: queue)
            
            guard let connection = videoOutput.connection(with: AVMediaType.video) else{return}
            connection.videoOrientation = currentVideoOrientation()
            if (connection.isVideoStabilizationSupported) {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            
        } catch{
            print(error)
        }
    }
    
    func setupPreviewLayer(){
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0) //layer 0
        
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        return orientation
    }
    
    
    func startRunningCaptureSession(){
        captureSession.startRunning()
    }
    
    
    
    @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
        //performSegue(withIdentifier: "show_segue", sender: nil)
        
    }
    
    
//    // MARK: Sample buffer to UIImage conversion
//    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
//        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
//        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
//        guard let cgImage = connect.createCGImage(ciImage, from: ciImage.extent) else { return nil }
//        return UIImage(cgImage: cgImage)
//    }
    
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // called all the time
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


}


