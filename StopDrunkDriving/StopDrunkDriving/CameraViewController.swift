//
//  CameraViewController.swift
//  StopDrunkDriving
//
//  Created by charles on 10/24/18.
//  Copyright © 2018 liang. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class CameraViewController: UIViewController {
    
    var captureSession = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Start the camera
        // **********************
        
        //Set the capture preset
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        
        // Add device
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else{return}
        captureSession.addInput(input)
        
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        
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
