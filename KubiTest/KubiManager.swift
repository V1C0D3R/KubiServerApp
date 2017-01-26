//
//  KubiManager.swift
//  KubiTest
//
//  Created by Victor Nouvellet on 1/23/17.
//  Copyright © 2017 Victor Nouvellet Inc. All rights reserved.
//

import Foundation
import KubiDeviceSDK

class KubiManager: NSObject  {
    
    static let sharedInstance = KubiManager()
    
    //HERE is the bug: deviceSDK not available in Swift... Waiting for a framework update...
    let kubiSdk: RRDeviceSDK = RRDeviceSDK.init(swiftSDK: ())
    
    var connectedDevice: RRDevice? { return self.kubiSdk.connectedDevice }
    var deviceConnectionState: RRDeviceConnectionState { return self.kubiSdk.deviceConnectionState }
    
    var deviceDidUpdateDeviceListCallback: ((_ deviceList: [Any]) -> ())? = nil
    var deviceDidChangeConnectionCallback: ((_ connectionState: RRDeviceConnectionState) -> ())? = nil
    
    // MARK: Parent methods
    
    override init() {
        super.init()
        
        self.configureRRDeviceSDKDelegate()
    }
    
    // MARK: Public methods
    
    func disconnectDevice() {
        self.kubiSdk.disconnectDevice()
    }
    
    func startScan() -> Bool {
        return self.kubiSdk.startScan()
    }
    
    func endScan() {
        self.kubiSdk.endScan()
    }
}

// MARK: - RRDeviceSDK delegate extension
extension KubiManager: RRDeviceSDKDelegate {
    func configureRRDeviceSDKDelegate() {
        self.kubiSdk.delegate = self
    }
    
    func deviceSDK(_ deviceSDK: RRDeviceSDK, didUpdateDeviceList deviceList: [Any]) {
        self.deviceDidUpdateDeviceListCallback?(deviceList)
    }
    
    func deviceSDK(_ deviceSDK: RRDeviceSDK, didChange connectionState: RRDeviceConnectionState) {
        self.deviceDidChangeConnectionCallback?(connectionState)
    }
}

// MARK: - Sample movements extension
extension KubiManager {
    func tiltUp() {
        guard let kubi = self.connectedDevice as? RRKubi
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
    
    func tiltDown() {
        guard let kubi = self.connectedDevice as? RRKubi
            else {
                print("[Warning] No Kubi connected = No remote control")
                return
        }
        
        do {
            try kubi.incrementalMove(withPanDelta: NSNumber(value: 0),
                                     atPanSpeed: NSNumber(value: 0),
                                     andTiltDelta: NSNumber(value: -20),
                                     atTiltSpeed: NSNumber(value: 150))
        } catch {
            print("Error doing incremental")
        }
    }
    
    func panLeft() {
        guard let kubi = self.connectedDevice as? RRKubi
            else {
                print("[Warning] No Kubi connected = No remote control")
                return
        }
        
        do {
            try kubi.incrementalMove(withPanDelta: NSNumber(value: -20),
                                     atPanSpeed: NSNumber(value: 150),
                                     andTiltDelta: NSNumber(value: 0),
                                     atTiltSpeed: NSNumber(value: 0))
        } catch {
            print("Error doing incremental")
        }
    }
    
    func panRight() {
        guard let kubi = self.connectedDevice as? RRKubi
            else {
                print("[Warning] No Kubi connected = No remote control")
                return
        }
        
        do {
            try kubi.incrementalMove(withPanDelta: NSNumber(value: 20),
                                     atPanSpeed: NSNumber(value: 150),
                                     andTiltDelta: NSNumber(value: 0),
                                     atTiltSpeed: NSNumber(value: 0))
        } catch {
            print("Error doing incremental")
        }
    }
}
