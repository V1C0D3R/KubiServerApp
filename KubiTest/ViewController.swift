//
//  ViewController.swift
//  KubiTest
//
//  Created by Victor Nouvellet on 1/23/17.
//  Copyright © 2017 Victor Nouvellet Inc. All rights reserved.
//

import UIKit
import GCDWebServer
import KubiDeviceSDK

class ViewController: UIViewController {
    
    @IBOutlet weak var scanIndicator: UIActivityIndicatorView?
    @IBOutlet weak var scanButton: UIButton?
    @IBOutlet weak var connectionView: UIView?
    @IBOutlet weak var controlView: UIView?
    @IBOutlet weak var topConstraint: NSLayoutConstraint?
    
    var connectionAlert: UIAlertController = UIAlertController()
    var isScanning: Bool = false
    var kubiManager: KubiManager = KubiManager.sharedInstance
    var webServer: GCDWebServer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureKubiManagerCallbacks()
        
        self.updateControlButtons()
        _ = self.startScanning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func scanButtonPressed(sender: UIButton) {
        self.updateControlButtons()
        _ = self.startScanning()
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
        
        // Create server
        self.webServer = GCDWebServer()
        
        // Add a handler to respond to GET requests on any URL
        self.webServer?.addDefaultHandler(forMethod: "GET",
                                          request: GCDWebServerRequest.self,
                                          asyncProcessBlock: { (request: GCDWebServerRequest?, completionBlock: GCDWebServerCompletionBlock?) in
                                            print("New client!")
                                            self.handleRequest(request: request, completionBlock: completionBlock)
        })
        
        // Start server on port 80
        self.webServer?.start(withPort: 80, bonjourName: "KUBI-Server")
        
        print("Visit \(self.webServer?.serverURL) or \(self.webServer?.bonjourServerURL) in your web browser")

    }
    
    // MARK: Private methods
    
    private func configureKubiManagerCallbacks() {
        self.kubiManager.deviceDidUpdateDeviceListCallback = { (deviceList: [Any]) in
            
            print("device SDK didUpdateDeviceList")
            
            if self.kubiManager.deviceConnectionState == .connecting || self.kubiManager.deviceConnectionState == .connecting {
                self.stopScanning()
                return
            }
            
            self.connectionAlert = UIAlertController(title: "Choose your device", message: "Here is the list of available devices", preferredStyle: .actionSheet)
            
            for device in deviceList {
                guard let safeDevice = device as? RRKubi else {
                    continue
                }
                let defaultAction: UIAlertAction = UIAlertAction(title: safeDevice.name(), style: .default, handler: { (action: UIAlertAction) in
                    
                    self.stopScanning()
                    self.kubiManager.kubiSdk.connect(safeDevice)
                })
                self.connectionAlert.addAction(defaultAction)
            }
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "Wait...", style: .destructive, handler: nil)
            self.connectionAlert.addAction(defaultAction)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "Stop scanning", style: .destructive, handler: {
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
        }   else    {
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
            
            self.controlView?.isHidden = true
        }
    }
    
    // MARK: - Scan functions
    
    func startScanning() -> Bool {
        self.scanButton?.isEnabled = false
        self.scanIndicator?.startAnimating()
        self.isScanning = self.kubiManager.startScan()
        return self.isScanning
    }
    
    func stopScanning() {
        self.kubiManager.endScan()
        self.isScanning = false
        self.scanButton?.isEnabled = false
        self.scanIndicator?.stopAnimating()
    }
    
    // MARK: - Remote Control
    
    @IBAction func tiltUpButtonPressed(sender: UIButton) {
        guard let kubi = self.kubiManager.connectedDevice as? RRKubi
            else {
                print("[Warning] No Kubi connected = No remote control")
                return
        }
        
        do {
            try kubi.incrementalMove(withPanDelta: NSNumber(value: 0),
                             atPanSpeed: NSNumber(value: 0),
                             andTiltDelta: NSNumber(value: 20),
                             atTiltSpeed: NSNumber(value: 150))
        } catch {
            print("Error doing incremental")
        }
    }
    
    @IBAction func tiltDownButtonPressed(sender: UIButton) {
        guard let kubi = self.kubiManager.connectedDevice as? RRKubi
            else {
                print("[Warning] No Kubi connected = No remote control")
                return
        }
        
        do {
            try kubi.incrementalMove(withPanDelta: NSNumber(value: 0),
                                     atPanSpeed: NSNumber(value: 0),
                                     andTiltDelta: NSNumber(value: 20),
                                     atTiltSpeed: NSNumber(value: 150))
        } catch {
            print("Error doing incremental")
        }
    }
    
    @IBAction func panRightButtonPressed(sender: UIButton) {
        guard let kubi = self.kubiManager.connectedDevice as? RRKubi
            else {
                print("[Warning] No Kubi connected = No remote control")
                return
        }
        
        do {
            try kubi.incrementalMove(withPanDelta: NSNumber(value: 0),
                                     atPanSpeed: NSNumber(value: 0),
                                     andTiltDelta: NSNumber(value: 20),
                                     atTiltSpeed: NSNumber(value: 150))
        } catch {
            print("Error doing incremental")
        }
    }
    
    @IBAction func panLeftButtonPressed(sender: UIButton) {
        guard let kubi = self.kubiManager.connectedDevice as? RRKubi
            else {
                print("[Warning] No Kubi connected = No remote control")
                return
        }
        
        do {
            try kubi.incrementalMove(withPanDelta: NSNumber(value: 0),
                                     atPanSpeed: NSNumber(value: 0),
                                     andTiltDelta: NSNumber(value: 20),
                                     atTiltSpeed: NSNumber(value: 150))
        } catch {
            print("Error doing incremental")
        }
    }
    
    // MARK: - Requests handling
    
    func handleRequest(request: GCDWebServerRequest?, completionBlock: GCDWebServerCompletionBlock?) {
        
        guard let device: RRDevice = self.kubiManager.connectedDevice,
            let kubi: RRKubi = device as? RRKubi,
            request?.url.relativePath == "/"
            else {
                print("No connected kubi")
                let responseFail = GCDWebServerResponse()
                completionBlock?(responseFail)
                return
        }
        
        if request?.query["panDelta"] != nil && request?.query["panSpeed"] != nil &&
            request?.query["tiltDelta"] != nil && request?.query["tiltSpeed"] != nil {
            let panDelta: NSNumber = request?.query["panDelta"] as? NSNumber ?? 0
            let panSpeed: NSNumber = request?.query["panSpeed"] as? NSNumber ?? 0
            let tiltDelta: NSNumber = request?.query["tiltDelta"] as? NSNumber ?? 0
            let tiltSpeed: NSNumber = request?.query["tiltSpeed"] as? NSNumber ?? 0
            
            do {
                try kubi.incrementalMove(withPanDelta: panDelta, atPanSpeed: panSpeed, andTiltDelta: tiltDelta, atTiltSpeed: tiltSpeed)
                let responseSuccess = GCDWebServerResponse()
                completionBlock?(responseSuccess)
            } catch {
                print("Error doing incremental")
                let responseFail = GCDWebServerResponse()
                completionBlock?(responseFail)
            }
            
        } else {
            
            let responseFail = GCDWebServerResponse()
            completionBlock?(responseFail)
        }
        
        
    }
}
