//
//  Region.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import MapKit

open class KMLRegion: KMLObject {

    @objc open var extent: KMLAbstractExtent?
    @objc open var lod: KMLLevelOfDetail?
    @objc open var metadata: [AnyObject] = []

}
