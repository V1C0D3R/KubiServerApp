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
//  KubiManager.swift
//  KubiServer
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
