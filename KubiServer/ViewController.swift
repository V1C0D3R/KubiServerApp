/*
 * Software License Agreement(New BSD License)
 * Copyright © 2017, Victor Nouvellet
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
//
//  ViewController.swift
//  KubiServer
//
//  Created by Victor Nouvellet on 1/23/17.
//  Copyright © 2017 Victor Nouvellet Inc. All rights reserved.
//

import UIKit
import AVFoundation
import lf
import VideoToolbox

class ViewController: UIViewController {
    
    @IBOutlet weak var scanIndicator: UIActivityIndicatorView?
    @IBOutlet weak var scanButton: UIButton?
    @IBOutlet weak var connectionView: UIView?
    @IBOutlet weak var autoConnectSwitch: UISwitch!
    @IBOutlet weak var controlView: UIView?
    @IBOutlet weak var topConstraint: NSLayoutConstraint?
    @IBOutlet weak var logViewContainer: UIView!
    @IBOutlet weak var webServerLog: UITextView!
    @IBOutlet weak var liveView: UIView!
    
    fileprivate var connectionAlert: UIAlertController = UIAlertController()
    fileprivate var isScanning: Bool = false
    fileprivate var kubiManager: KubiManager = KubiManager.sharedInstance
    fileprivate var serverHelper: ServerHelper = ServerHelper.sharedInstance
    fileprivate var visualSaver: VisualSaver = VisualSaver()
    fileprivate var cameraPosition:AVCaptureDevicePosition = .front
    fileprivate var autoConnect: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "autoconnect")
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: "autoconnect")
        }
    }
    
    //TODO: Move Streaming var/func to helper
    fileprivate var camera = DeviceUtil.device(withPosition: .front)
    var httpStream:HTTPStream? = nil
    var streamingHttpService:HTTPService? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.autoConnectSwitch.isOn = self.autoConnect
        
        self.configureKubiManagerCallbacks()
        
        self.updateControlButtons()
        
        // Start searching for Kubis
        self.startScanning()
        
        // Init web server
        self.configureWebServer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func scanButtonPressed(sender: UIButton) {
        self.updateControlButtons()
        self.kubiManager.disconnectDevice()
        self.startScanning()
    }
    
    @IBAction func disconnectButtonPressed(sender: UIButton) {
        self.kubiManager.disconnectDevice()
    }
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        if let kubi = self.kubiManager.connectedDevice as? RRKubi {
            // shareControlWithAppData method seems to be broken
            //        [self.sdk shareControlWithAppData:nil success:^{
            //            NSLog(@"SUCCESS");
            //        } fail:^(NSError * _Nullable error) {
            //            NSLog(@"FAIL");
            //        }];
            print("Identifier : %@ \n Type : %@", kubi.identifier, kubi.type)
        }
    }
    
    @IBAction func autoconnectSwitchValueChanged(_ sender: Any) {
        self.autoConnect = self.autoConnectSwitch.isOn
    }
    
    @IBAction func streamButtonPressed(sender: UIButton) {
        self.configureStreaming()
    }
    
    @IBAction func liveViewDoubleTapped(_ sender: Any) {
        
        let newCameraPosition: AVCaptureDevicePosition = ((self.cameraPosition == .front) ? .back : .front)
        self.httpStream?.attachCamera(DeviceUtil.device(withPosition: newCameraPosition))
        self.cameraPosition = newCameraPosition
        self.addMessageToLog(message: "Camera changed to \(newCameraPosition == .back ? "back" : "front")")
    }
    
    // MARK: Private methods
    
    private func configureWebServer() {
        self.configureServerHelperDelegate()
        self.serverHelper.kubiManager = self.kubiManager
        self.serverHelper.lastImageCallback = { (compressionQuality: CGFloat)->Data? in
            if let ciimage = self.visualSaver.lastImage {
                let context:CIContext = CIContext.init(options: nil)
                let cgImage:CGImage = context.createCGImage(ciimage, from: ciimage.extent)!
                let image:UIImage = UIImage.init(cgImage: cgImage)
                if let data: Data = UIImageJPEGRepresentation(image, compressionQuality) {
                    return data
                }
            }
            return nil
        }
        
        if self.serverHelper.initServer(), let safeServerUrl = self.serverHelper.serverUrl?.absoluteString {
            let successMessage = "Visit \(safeServerUrl) in your web browser"
            print(successMessage)
            self.addMessageToLog(message: successMessage)
        } else {
            let failMessage = "Web server failed to initialize correctly. Are you connected to a Wifi network?"
            print(failMessage)
            self.addMessageToLog(message: failMessage)
        }
    }
    
    private func configureStreaming() {
        if self.initHLS() {
            let relativeUrl = "\((self.serverHelper.serverUrl?.host ?? "")!)/kubi/playlist.m3u8"
            self.addMessageToLog(message: "Streaming initialized with success. Here is the streaming url : \(relativeUrl)")
        } else {
            self.addMessageToLog(message: "Streaming failed to initialize. Check your Wifi connection and try again!")
        }
    }
    
    private func configureKubiManagerCallbacks() {
        self.kubiManager.deviceDidUpdateDeviceListCallback = { (deviceList: [Any]) in
            
            print("device SDK didUpdateDeviceList")
            
            if self.kubiManager.deviceConnectionState == .connecting || self.kubiManager.deviceConnectionState == .connected {
                self.stopScanning()
                return
            }
            
            self.connectionAlert = UIAlertController(title: "Choose your device", message: "Here is the list of available devices", preferredStyle: .actionSheet)
            
            for (index, device) in deviceList.enumerated() {
                guard let safeDevice = device as? RRKubi else {
                    continue
                }
                
                //Auto connect
                if index == 0 && self.autoConnect { self.kubiManager.kubiSdk.connect(safeDevice) }
                    
                let defaultAction: UIAlertAction = UIAlertAction(title: safeDevice.name(), style: .default, handler: { (action: UIAlertAction) in
                    
                    self.stopScanning()
                    self.kubiManager.kubiSdk.connect(safeDevice)
                })
                self.connectionAlert.addAction(defaultAction)
            }
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "Wait...", style: .destructive, handler: nil)
            self.connectionAlert.addAction(defaultAction)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "Stop scanning", style: .cancel, handler: {
                (action: UIAlertAction) in
                self.stopScanning()
            })
            self.connectionAlert.addAction(cancelAction)
            
            if !self.connectionAlert.isBeingPresented && self.isScanning == true {
                self.present(self.connectionAlert, animated: true, completion: nil)
            }
        }
        
        self.kubiManager.deviceDidChangeConnectionCallback = { (connectionState: RRDeviceConnectionState) in
            
            print("device SDK didChangeConnectionState")
            
            self.updateControlButtons()
            switch connectionState {
            case .connected:
                self.connectionAlert.dismiss(animated: true, completion: nil)
                if let kubi = self.kubiManager.connectedDevice as? RRKubi {
                    do {
                        try kubi.setPanEnabled(true)
                        try kubi.setTiltEnabled(true)
                    } catch {
                        print("[WARNING] Tilt or Pan not enabled properly")
                    }
                }
                if self.autoConnect { self.configureStreaming() }
                
                break
            case .connecting:
                self.connectionAlert.dismiss(animated: true, completion: nil)
                break
            case .disconnected:
                break
            case .connectionLost:
                break
            }
        }
    }
    
    func addMessageToLog(message: String) {
        self.webServerLog.text = self.webServerLog.text.appending("\(message)\n")
    }
    
    // MARK: - Scan functions
    
    @discardableResult func startScanning() -> Bool {
        self.isScanning = true
        self.scanButton?.isEnabled = false
        self.scanIndicator?.startAnimating()
        return self.kubiManager.startScan()
    }
    
    func stopScanning() {
        self.kubiManager.endScan()
        self.scanIndicator?.stopAnimating()
        self.scanButton?.isEnabled = true
        self.isScanning = false
    }
    
    // MARK: - Remote Control
    
    private func updateControlButtons() {
        if self.kubiManager.deviceConnectionState == .connected {
            UIView.animate(withDuration: 1.5,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseInOut,
                           animations: {
                            self.topConstraint?.constant = 20
                            self.view.layoutIfNeeded()
            }, completion: { (complete: Bool) in
                //What to do after completion
            })
            
            self.controlView?.isHidden = false
            self.logViewContainer?.isHidden = false
        }   else    {
            UIView.animate(withDuration: 1.5,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseInOut,
                           animations: {
                            self.topConstraint?.constant = 250
                            self.view.layoutIfNeeded()
            }, completion: { (complete: Bool) in
                //What to do after completion
            })
            
            self.controlView?.isHidden = true
            self.logViewContainer?.isHidden = true
        }
    }
    
    @IBAction func tiltUpButtonPressed(sender: UIButton) {
        self.kubiManager.tiltUp()
    }
    
    @IBAction func tiltDownButtonPressed(sender: UIButton) {
        self.kubiManager.tiltDown()
    }
    
    @IBAction func panLeftButtonPressed(sender: UIButton) {
        self.kubiManager.panLeft()
    }
    
    @IBAction func panRightButtonPressed(sender: UIButton) {
        self.kubiManager.panRight()
    }
}

// MARK: - ServerHelper delegate extension
extension ViewController: ServerHelperDelegate {
    func configureServerHelperDelegate() {
        self.serverHelper.delegate = self
    }
    
    func serverHelperSucceededToSatisfyRequestCommand(url: URL?, path: String?, query: [AnyHashable : Any]?) {
        DispatchQueue.main.async {
            self.addMessageToLog(message: "[Request satisfied] URL: \((url?.absoluteString ?? "Hidden")!). Query : \((query?.description ?? "Hidden")!)")
        }
    }
    
    func serverHelperFailedToSatisfyRequestCommand(error: NSError) {
        DispatchQueue.main.async {
            self.addMessageToLog(message:"Request failed : \(error.description)")
        }
    }
    
    func serverHelperHaveNewClientConnected(url: URL?) {
        DispatchQueue.main.async {
            self.addMessageToLog(message:"New client connection. URL : \(url?.absoluteString ?? "Unknown url")")
        }
    }
}

// MARK: - Streaming methods extension
extension ViewController {
    func initHLS() -> Bool {
        self.httpStream = HTTPStream()
        self.httpStream?.attachCamera(self.camera)
        self.httpStream?.attachAudio(AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio))
        
        self.httpStream?.videoSettings = [
            "bitrate": 160 * 1024, // video output bitrate
            "width": 272,
            "height": 480,
            //            "dataRateLimits": [160 * 1024 / 8, 1], //optional kVTCompressionPropertyKey_DataRateLimits property
            "profileLevel": kVTProfileLevel_H264_Baseline_5_1, // H264 Profile require "import VideoToolbox"
            "maxKeyFrameIntervalDuration": 0.2, // key frame / sec
        ]
        
        self.httpStream?.publish("kubi")
        
        if let safeHttpStream = self.httpStream {
            let lfView:LFView = LFView(frame: self.liveView.bounds)
            lfView.attachStream(httpStream)
            
            //Last image output setup
            if httpStream?.registerEffect(video: self.visualSaver) ?? false {
                print("lastImage configured successfully")
            }
            
            // Streaming HTTP Service setup
            self.streamingHttpService = HTTPService(domain: "", type: "_http._tcp", name: "lf", port: 80)
            self.streamingHttpService?.startRunning()
            self.streamingHttpService?.addHTTPStream(safeHttpStream)
            
            self.liveView.addSubview(lfView)
            
            return true
        }
        
        return false
    }
}
