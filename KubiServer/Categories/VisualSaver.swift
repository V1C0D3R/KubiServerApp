//
//  VisualEffect.swift
//  KubiServer
//
//  Created by Victor Nouvellet on 2/17/17.
//  Copyright © 2017 Victor Nouvellet Inc. All rights reserved.
//

import Foundation
import CoreImage
import lf

class VisualSaver: VisualEffect {
    var lastImage:CIImage? = nil
    override func execute(_ image: CIImage) -> CIImage {
        self.lastImage = super.execute(image)
        return image
    }
}
