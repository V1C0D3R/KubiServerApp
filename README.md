<p align="center">
  <img src="https://cloud.githubusercontent.com/assets/4340716/22605826/6cb27cfe-ea06-11e6-803c-f069feb71760.png" alt="Kubi Server App" height="200" width="200"/>
</p>
# Kubi Server App [![GitHub license](https://img.shields.io/badge/license-New%20BSD-blue.svg)](https://raw.githubusercontent.com/V1C0D3R/KubiServerApp/master/LICENCE.txt)

![platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)

Control your Kubi on your local network with a iOS gateway.

This repository contains the source code for Kubi Server iOS app.

This app consists in:

 * Exposing a Kubi control API on local iOS device network.
 * Exposing a video live streaming endpoint.

## Installation Requirements

- Xcode
- Cocoapods >=1.2.0

> Important note: *Kubi framework has not been compiled for the iOS simulator so you will not be able to install KubiServer app on it.*

## Installation

1. Fork or download project.
- Open Xcode.
- Add Kubi framework to your project. You can download it [here](https://cdn.kubi.me/?prefix=Files/sdk-ios/).
- From Terminal, use `pod install` to install [HaishinKit](https://github.com/shogo4405/lf.swift) and [GCDWebServer](https://github.com/swisspol/GCDWebServer) pods.  
6. Compile on your device.


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
####Absolute position example:
> `http://IOS_IP_ADDRESS:8080/absolute?pan=0&panSpeed=40&tilt=-10&tiltSpeed=50`

####Incremental position example: 
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


