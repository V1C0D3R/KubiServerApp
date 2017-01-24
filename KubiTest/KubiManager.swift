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
    let kubiSdk = RRDeviceSDK.deviceSDK()
    
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
