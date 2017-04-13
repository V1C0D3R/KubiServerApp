<p align="center">
  <img src="https://cloud.githubusercontent.com/assets/4340716/22605826/6cb27cfe-ea06-11e6-803c-f069feb71760.png" alt="Kubi Server App" height="200" width="200"/>
</p>

# Kubi Server App 
[![GitHub license](https://img.shields.io/badge/license-New%20BSD-blue.svg)](https://raw.githubusercontent.com/V1C0D3R/KubiServerApp/master/LICENCE.txt) ![platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)

Control your Kubi on your local network with a iOS gateway.

This repository contains the source code for Kubi Server iOS app.

This app consists in:

 * Exposing a Kubi control API on local iOS device network.
 * Exposing a video live streaming endpoint.

## Installation Requirements

- [Xcode](https://developer.apple.com/xcode/)
- [Cocoapods](https://guides.cocoapods.org/using/getting-started.html) ≥1.2.0

> Important note: *Kubi framework has not been compiled for the iOS simulator so you will not be able to install KubiServer app on it.*

## Installation

1. Clone or [download](https://github.com/V1C0D3R/KubiServerApp/archive/master.zip) project.
- From root project directory in Terminal (the one where Podfile file is), run `pod repo update` to update source repos and then run `pod install`. It will install [HaishinKit](https://github.com/shogo4405/lf.swift) and [GCDWebServer](https://github.com/swisspol/GCDWebServer) pods.
- Run `open KubiServer.xcworkspace` to open the project workspace in Xcode.
- Download last Kubi framework: from [this page](https://cdn.kubi.me/?prefix=Files/sdk-ios/), download KubiDeviceSDK-iOS-X.X.zip file and unzip it. Only KubiDeviceSDK version 1.5 has been tested but next versions should work.
- From the unzipped folder, drag and drop __KubiDeviceSDK.framework__ file to Xcode under __Frameworks__ folder. Make sure to check Copy items if needed, so that the files actually copy into the new project instead of just adding a reference. Frameworks need their own code, not references, to be independent.<img width="450" alt="screen shot 2017-02-15 at 4 01 36 pm" src="https://cloud.githubusercontent.com/assets/4340716/23001320/9136f5b8-f399-11e6-96af-3f3afcaf585c.png">
- Add the framework to the "Embedded binaries" section in the "General" tab of KubiServer app target.![addtoembeddedbinaries](https://cloud.githubusercontent.com/assets/4340716/23001293/7200a8d8-f399-11e6-8152-8624a861f8e3.png)
6. Make sure your device is connected to your computer and Build & Run by using ⌘+R from Xcode.


## User Steps after installation

- Open the app (control API will automatically be deployed)
- Connect using Bluetooth to the Kubi using the 'Scan' button. You can check Kubi connectivity using control buttons
- Tap 'Stream camera' button to deploy streaming API
- Use control & streaming URLs added

The control server should be running even if the app is in background but the video stream server will pause. See why [here](https://github.com/shogo4405/lf.swift).

## Play live

Use your favorite HLS player.
With Quicktime:
- Open Quicktime.
- Go to the menu File > Open location...
- In the window that pops up, enter in the playlist URL given in visible app log. It should be something like that: *`http://IOS_IP_ADDRESS/kubi/playlist.m3u8`*

## Control live

The API is accessible from *`http://IOS_IP_ADDRESS:8080`*
Absolute and incremental position API are accessed through `/absolute` and `/incremental` paths.

#### Absolute position example:
> `http://IOS_IP_ADDRESS:8080/absolute?pan=0&panSpeed=40&tilt=-10&tiltSpeed=50`

#### Incremental position example: 
> `http://IOS_IP_ADDRESS:8080/incremental?pan=0&panSpeed=40&tilt=-10&tiltSpeed=50`

## Contributing

Everything works around one branch (`master`) to follow the [Github Flow](https://guides.github.com/introduction/flow/). 
Feel free to submit pull requests.
Test your (not yet tested) code if possible before pull requests.

## Needed pods
 * [HaishinKit](https://github.com/shogo4405/lf.swift)
 * [GCDWebServer](https://github.com/swisspol/GCDWebServer)

## Authors
 * Victor Nouvellet - victor (dot) nouvellet (at) gmail (dot) com

## License
 * KubiServer is released under a New BSD License. See LICENSE file for details.

## See also
* [Accessors](http://accessors.org)
* [Kubi](https://www.revolverobotics.com/)


