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
//  ServerHelper.swift
//  KubiServer
//
//  Created by Victor Nouvellet on 1/24/17.
//  Copyright © 2017 Victor Nouvellet Inc. All rights reserved.
//

import Foundation
import GCDWebServer

protocol ServerHelperDelegate {
    func serverHelperHaveNewClientConnected(url: URL?)
    func serverHelperFailedToSatisfyRequestCommand(error: NSError)
    func serverHelperSucceededToSatisfyRequestCommand(url: URL?, path: String?, query: [AnyHashable : Any]?)
}

class ServerHelper {
    
    // MARK: - Public properties
    
    // MARK: Principal public properties
    static let sharedInstance = ServerHelper()
    var kubiManager: KubiManager? = nil
    var delegate: ServerHelperDelegate? = nil
    var lastImageCallback: ((_ compressionQuality: CGFloat)->Data?)? = nil
    
    // Paths
    enum ServerPath: String {
        case root = "/"
        case incremental = "/incremental"
        case absolute = "/absolute"
        case live = "/live"
        case livePlaylist = "/kubi/playlist.m3u8"
        case lastImage = "/lastImage"
        
        static let supportedPaths: [ServerPath] = [.root, .incremental, .absolute, .live, .livePlaylist, .lastImage]
    }
    
    // MARK: Other public properties
    var serverUrl: URL? {
        get {
            return self.webServer?.serverURL
        }
    }
    
    var bonjourServerURL: URL? {
        get {
            return self.webServer?.bonjourServerURL
        }
    }
    
    // MARK: - Private properties
    private var webServer: GCDWebServer? = nil
    private let serialQueue = DispatchQueue(label: "kubi-command-queue")
    
    // MARK: Server Initialization
    
    @discardableResult func initServer() -> Bool {
        guard self.webServer == nil else {
            print("Server already initialized")
            return false
        }
        
        // Create server
        self.webServer = GCDWebServer()
        
        self.addControlHandlers(webServer: self.webServer)
        
        // Start server on port 8080
        return self.webServer?.start(withPort: 8080, bonjourName: "KUBI-Server") ?? false
    }
    
    func addControlHandlers(webServer: GCDWebServer?) {
        webServer?.addHandler(forMethod: "GET", pathRegex: "/.*.ico", request: GCDWebServerRequest.self, asyncProcessBlock: self.handleRequest)
        webServer?.addHandler(forMethod: "GET", path: "/", request: GCDWebServerRequest.self, asyncProcessBlock: self.handleRequest)
        webServer?.addHandler(forMethod: "GET", path: "/incremental", request: GCDWebServerRequest.self, asyncProcessBlock: self.handleRequest)
        webServer?.addHandler(forMethod: "GET", path: "/absolute", request: GCDWebServerRequest.self, asyncProcessBlock: self.handleRequest)
        webServer?.addHandler(forMethod: "GET", path: "/live", request: GCDWebServerRequest.self, asyncProcessBlock: self.handleRequest)
        webServer?.addHandler(forMethod: "GET", path: "/lastImage", request: GCDWebServerRequest.self, asyncProcessBlock: self.handleRequest)
    }
    
    // MARK: Requests handling
    
    func moveKubi(kubi: RRKubi, withPanDelta pan: NSNumber?, atPanSpeed panSpeed: NSNumber?, andTiltDelta tilt: NSNumber?, atTiltSpeed tiltSpeed: NSNumber?) {
        DispatchQueue.main.sync {
            do {
                try kubi.incrementalMove(withPanDelta: pan, atPanSpeed: panSpeed, andTiltDelta: tilt, atTiltSpeed: tiltSpeed)
            } catch {
                print("Error")
            }
        }
    }
    
    func handleRequest(request: GCDWebServerRequest?, completionBlock: GCDWebServerCompletionBlock?) {
        
        // Ignore .ico requests
        if request?.url.absoluteString.contains(".ico") ?? false {
            self.delegate?.serverHelperSucceededToSatisfyRequestCommand(url: request?.url, path: request?.path, query: request?.query)
            let responseIgnore = GCDWebServerResponse(statusCode: 404)
            print(".ico request ignored")
            completionBlock?(responseIgnore)
            return
        }
        
        guard let safeRequest = request, let supportedPath = ServerPath(rawValue: safeRequest.url.relativePath) else {
            let errorDescription = "404: Not Found. Request on \((request?.url.absoluteString ?? "<Unknown URL>")!)"
            print(errorDescription)
            let error = self.error(withDescription: errorDescription, code: 404)
            
            self.delegate?.serverHelperFailedToSatisfyRequestCommand(error: error)
            let responseFail = self.response(message: errorDescription, error: error)
            completionBlock?(responseFail)
            return
        }
        
        self.delegate?.serverHelperHaveNewClientConnected(url: safeRequest.url)
        
        // Live streaming endpoints
        if supportedPath == .livePlaylist {
            self.delegate?.serverHelperSucceededToSatisfyRequestCommand(url: safeRequest.url, path: safeRequest.path, query: safeRequest.query)
            return
        } else if supportedPath == .live {
            let liveWebPagePath = Bundle.main.path(forResource: "index", ofType: "html")
            let variables = Dictionary(dictionaryLiteral: ("liveUrl", "\((self.serverUrl?.host ?? "")!)/kubi/playlist.m3u8"))
            let response = GCDWebServerDataResponse(htmlTemplate: liveWebPagePath ?? "", variables: variables)
            completionBlock?(response)
            return
        } else if supportedPath == .lastImage {
            //TODO: Pick UIImage from camera and use this as fallback
            if let imageData = self.lastImageCallback?(0.2) {
                let response = GCDWebServerDataResponse(data: imageData, contentType: "image/jpeg")
                completionBlock?(response)
            }
            
            return
        }
        
        // Kubi device related endpoints
        guard let device: RRDevice = self.kubiManager?.connectedDevice, let kubi: RRKubi = device as? RRKubi else {
            let errorDescription = "[KubiError] No connected kubi"
            print(errorDescription)
            let error = self.error(withDescription: errorDescription)
            
            self.delegate?.serverHelperFailedToSatisfyRequestCommand(error: error)
            let responseFail = self.response(message: errorDescription, error: error)
            completionBlock?(responseFail)
            return
        }
        
        // Kubi Routing
        if supportedPath == .root || supportedPath == .incremental {
            self.incrementalMoveHandling(request: safeRequest, kubi: kubi, completionBlock: completionBlock)
        } else if supportedPath == .absolute {
            self.absoluteMoveHandling(request: safeRequest, kubi: kubi, completionBlock: completionBlock)
        }
    }
    
    fileprivate func absoluteMoveHandling(request: GCDWebServerRequest, kubi: RRKubi, completionBlock: GCDWebServerCompletionBlock?) {
        if let panParam = request.query["pan"] as? String, let panSpeedParam = request.query["panSpeed"] as? String,
            let tiltParam = request.query["tilt"] as? String, let tiltSpeedParam = request.query["tiltSpeed"] as? String {
            let pan: NSNumber = NSNumber(value: Double(panParam) ?? 0)
            let panSpeed: NSNumber = NSNumber(value: Double(panSpeedParam) ?? 0)
            let tilt: NSNumber = NSNumber(value: Double(tiltParam) ?? 0)
            let tiltSpeed: NSNumber = NSNumber(value: Double(tiltSpeedParam) ?? 0)
            
            do {
                try kubi.absoluteMove(toPan: pan, atPanSpeed: panSpeed, andTilt: tilt, atTiltSpeed: tiltSpeed)
                
                //TODO: Change to GCDWebServerDataResponse(jsonObject: Any!)
                let responseSuccess = self.response(message: "{ \"status\": \"success\", \"data\":{\"kubiName\":\"\(kubi.name())\", \"description\": \"Kubi \(kubi.name()) just moved\"} }")
                completionBlock?(responseSuccess)
                
                
                self.delegate?.serverHelperSucceededToSatisfyRequestCommand(url: request.url, path: request.path, query: request.query)
            } catch {
                let errorDescription = "[KubiError] Error: Incremental move failed"
                print(errorDescription)
                let error = self.error(withDescription: errorDescription, code: 200)
                
                let responseFail = self.response(message: errorDescription, error: error)
                completionBlock?(responseFail)
                self.delegate?.serverHelperFailedToSatisfyRequestCommand(error: error)
            }
            
        } else {
            let controlUrlExample = "\"\(request.url.baseURL?.absoluteString)?pan=0&panSpeed=0&tilt=20&tiltSpeed=150\""
            let errorDescription = "Missing parameter(s). Needed parameters: pan, panSpeed, tilt, tiltSpeed.<br/>You can use <a href=\(controlUrlExample)>this example</a>."
            print(errorDescription)
            let error = self.error(withDescription: errorDescription, code: 200)
            
            self.delegate?.serverHelperFailedToSatisfyRequestCommand(error: error)
            let responseFail = self.response(message: errorDescription, error: error)
            completionBlock?(responseFail)
        }
    }
    
    fileprivate func incrementalMoveHandling(request: GCDWebServerRequest, kubi: RRKubi, completionBlock: GCDWebServerCompletionBlock?) {
        if let panDeltaParam = request.query["panDelta"] as? String, let panSpeedParam = request.query["panSpeed"] as? String,
            let tiltDeltaParam = request.query["tiltDelta"] as? String, let tiltSpeedParam = request.query["tiltSpeed"] as? String {
            let panDelta: NSNumber = NSNumber(value: Double(panDeltaParam) ?? 0)
            let panSpeed: NSNumber = NSNumber(value: Double(panSpeedParam) ?? 0)
            let tiltDelta: NSNumber = NSNumber(value: Double(tiltDeltaParam) ?? 0)
            let tiltSpeed: NSNumber = NSNumber(value: Double(tiltSpeedParam) ?? 0)
            
            do {
                try kubi.incrementalMove(withPanDelta: panDelta, atPanSpeed: panSpeed, andTiltDelta: tiltDelta, atTiltSpeed: tiltSpeed)
                
                //TODO: Change to GCDWebServerDataResponse(jsonObject: Any!)
                let responseSuccess = self.response(message: "{ \"status\": \"success\", \"data\":{\"kubiName\":\"\(kubi.name())\", \"description\": \"Kubi \(kubi.name()) just moved\"} }")
                completionBlock?(responseSuccess)
                
                self.delegate?.serverHelperSucceededToSatisfyRequestCommand(url: request.url, path: request.path, query: request.query)
            } catch {
                let errorDescription = "[KubiError] Error: Incremental move failed"
                print(errorDescription)
                let error = self.error(withDescription: errorDescription, code: 200)
                
                let responseFail = self.response(message: errorDescription, error: error)
                completionBlock?(responseFail)
                self.delegate?.serverHelperFailedToSatisfyRequestCommand(error: error)
            }
            
        } else {
            let controlUrlExample = "\"\(request.url.baseURL?.absoluteString)?panDelta=0&panSpeed=0&tiltDelta=20&tiltSpeed=150\""
            let errorDescription = "Missing parameter(s). Needed parameters: panDelta, panSpeed, tiltDelta, tiltSpeed.<br/>You can use <a href=\(controlUrlExample)>this example</a>."
            print(errorDescription)
            let error = self.error(withDescription: errorDescription, code: 200)
            
            self.delegate?.serverHelperFailedToSatisfyRequestCommand(error: error)
            let responseFail = self.response(message: errorDescription, error: error)
            completionBlock?(responseFail)
        }
    }
    
    // MARK: Errors handling
    
    private func getState() -> [String:Any] {
        var state: [String:AnyObject] = [:]
        state["kubiManagerLinked"] = NSNumber(value:(self.kubiManager != nil))
        state["kubiConnected"] = NSNumber(value:(self.kubiManager?.connectedDevice != nil))
        
        return state
    }
    
    private func error(withDescription description: String, code: Int = 0) -> NSError {
        var errorDescription = self.getState()
        errorDescription["description"] = description
        
        return NSError(domain: "Server", code: code, userInfo: errorDescription)
    }
    
    // MARK: Response handling
    
    private func response(message: String, error: NSError? = nil) -> GCDWebServerResponse {
        let html = "<html><body><p>\(message)</p></body></html>"
        let response: GCDWebServerResponse = GCDWebServerDataResponse(html: html) ?? GCDWebServerResponse(statusCode: error?.code ?? 200)
        return response
    }
}
