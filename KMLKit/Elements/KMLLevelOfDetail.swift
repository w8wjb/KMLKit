//
//  Lod.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

open class KMLLevelOfDetail: KMLObject {

    @objc open var minLodPixels: Double = 0.0
    @objc open var maxLodPixels: Double = -1.0
    @objc open var minFadeExtent: Double = 0.0
    @objc open var maxFadeExtent: Double = 0.0
    
}
