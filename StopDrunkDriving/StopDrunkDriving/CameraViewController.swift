//
//  CameraViewController.swift
//  StopDrunkDriving
//
//  Created by charles on 10/24/18.
//  Copyright © 2018 liang. All rights reserved.
//

import UIKit
import AVFoundation
import Photos


class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var alphaLayer: UIView!
    var captureSession = AVCaptureSession()
    var frontCamera : AVCaptureDevice?
    
    //var videoOutput = AVCaptureVideoDataOutput()
    var videoOutput = AVCaptureMovieFileOutput()


    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    var cameraOrientation: UIDeviceOrientation?
    var isRecording = false
    var maxVideoRecordTime = 6000
    var block:UIView!


    
//    var fileOutput : AVCaptureMovieFileOutput! //change the orientation to landscape


    override func viewDidLoad() {
        super.viewDidLoad()
        //alphaLayer.isHidden=true
        self.view.bringSubviewToFront(startButton)
        

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
            //videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: NSNumber(value: kCVPixelFormatType_32BGRA)]
            //videoOutput.alwaysDiscardsLateVideoFrames = true
            //let queue = DispatchQueue(label: "com.liang")
            //videoOutput.setSampleBufferDelegate(self, queue: queue)
            
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }

            
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
        //captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    
    
    @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
        //performSegue(withIdentifier: "show_segue", sender: nil)
        if !isRecording {
            //record new video
            print("button pressed")
            guard let outputURL = self.applicationDocumentsDirectory()?.appendingPathComponent("video").appendingPathExtension("mov") else {return}
            print(outputURL)
            videoOutput.startRecording(to: outputURL, recordingDelegate: self)
            self.isRecording = true
            
            //********
            block = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
            //block.center.y = self.view.bounds.height / 2
            block.backgroundColor = UIColor.white
            self.view.addSubview(block)
            self.view.bringSubviewToFront(block)
            alphaLayer.isHidden = false
            print("GGG")
            
            UIView.animate(withDuration: 8, delay: 0, options: .autoreverse,animations: {
                self.block.center.y += UIScreen.main.bounds.height
            }, completion: nil)
            //*******
        } else {
            //stop the camera recording
            videoOutput.stopRecording()
            self.isRecording = false
            print("recording stopped")
        }
    }
    
//    // MARK: Sample buffer to UIImage conversion
//    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
//        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
//        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
//        guard let cgImage = connect.createCGImage(ciImage, from: ciImage.extent) else { return nil }
//        return UIImage(cgImage: cgImage)
//    }
    
    func getImageFromSampleBuffer(samplerBuffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(samplerBuffer){
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect){
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return nil
    }
    
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
            if (error != nil) {
                print("Error recording movie: \(error!.localizedDescription)")
            }
        print("finished")
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { saved, error in
            if saved {
                let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }

        

        //performSegue(withIdentifier: "show_segue", sender: nil)
        }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {

    }

    
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // called all the time
        print(videoOutput)
        print("recording finished")
    }
    
    

    
    
    
        
    // helper func
    func applicationDocumentsDirectory() -> URL?{
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
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


