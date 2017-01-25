//
//  ScannerController.swift
//  NisanScanner
//
//  Created by Radu Tothazan on 02/12/2016.
//  Copyright © 2016 Radu Tothazan. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerController: UIViewController,  AVCaptureMetadataOutputObjectsDelegate{
    
    var produse : [Produs]!
    @IBOutlet weak var backButton: UIButton!
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var videoCaptureDevice : AVCaptureDevice!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (session?.isRunning == false) {
            session.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (session?.isRunning == true) {
            session.stopRunning()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = AVCaptureSession()
        
        videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        let videoInput: AVCaptureDeviceInput?
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (session.canAddInput(videoInput)) {
            session.addInput(videoInput)
        } else {
            scanningNotPossible()
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (session.canAddOutput(metadataOutput)) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypePDF417Code]
            
        } else {
            scanningNotPossible()
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session);
        previewLayer.frame = view.layer.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        view.layer.addSublayer(previewLayer);
        view.addSubview(backButton)
        
        session.startRunning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first
        let screenSize = previewLayer.bounds.size
        let focusPoint = CGPoint(x: (touchPoint?.location(in: self.view).y)! / screenSize.height, y: 1.0 - (touchPoint?.location(in: self.view).x)! / screenSize.width)
        let device = videoCaptureDevice!
        do {
            try device.lockForConfiguration()
            
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = focusPoint
                device.focusMode = AVCaptureFocusMode.autoFocus
            }
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = AVCaptureExposureMode.autoExpose
            }
            
            device.unlockForConfiguration()
            
        }catch{
            print(error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scanningNotPossible() {
        // Let the user know that scanning isn't possible with the current device.
        let alert = UIAlertController(title: "Can't Scan.", message: "Let's try a device equipped with a camera.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        session = nil
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        if let barcodeData = metadataObjects.first {
            let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject;
            if let readableCode = barcodeReadable {
                barcodeDetected(code: readableCode.stringValue);
            }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            // Avoid a very buzzy device.
            session.stopRunning()
        }
    }
    
    func barcodeDetected(code: String) {
        var message = ""
        var denumireProdus = ""
        for produs in produse{
            if produs.codBare == code{
                let tvaInt = Double(produs.tva)
                let pretAchizitieDouble = Double(produs.pretAchizitie)
                message += "Pret achizitie : \(((tvaInt! / 100) * pretAchizitieDouble!) + pretAchizitieDouble!)\nPret vanzare : \(produs.pretVanzare!)\nStoc : \(produs.stoc!)\n"
                denumireProdus = produs.nume
            }
        }
        
        let alert = UIAlertController(title: denumireProdus, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Anulare", style: .cancel, handler:{(alert: UIAlertAction!) in
            if (self.session?.isRunning == false) {
                self.session.startRunning()
            }
        })
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

}
