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
    var lastRawImage: CIImage? = nil
    var lastImage:CIImage? {
        guard let safeRawImage = self.lastRawImage else {
            return nil
        }
        let filteredImage: CIImage
        
        if let safeFilterName = self.filterName, self.supportedFilters.contains(safeFilterName) {
            filteredImage = self.applyFilterChain(to: safeRawImage, filterName: safeFilterName)
        } else {
            filteredImage = safeRawImage
        }
        
        return filteredImage
    }
    var filterName: String? = nil
    
    let supportedFilters: Array<String> = CIFilter.filterNames(inCategories: nil)
    
    override func execute(_ image: CIImage) -> CIImage {
        
        self.lastRawImage = super.execute(image)
        return image
    }
    
    func applyFilterChain(to image: CIImage, filterName: String) -> CIImage {
        // The CIPhotoEffectInstant filter takes only an input image
        let colorFilter = CIFilter(name: filterName, withInputParameters:
            [kCIInputImageKey: image])!
        
        return colorFilter.outputImage!
    }
}
