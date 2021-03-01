//
//  Region.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import MapKit

public class KMLRegion: KMLObject {

    @objc public var latLonAltBox: KMLLatLonAltBox?
    @objc public var extent: KMLAbstractExtent?
    @objc public var lod: KMLLod?
    @objc public var metadata: [AnyObject] = []

}
