//
//  Region.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import MapKit

public class KMLRegion: KMLObject {

    public var latLonAltBox: KMLLatLonAltBox?
    public var lod: KMLLod?
    public var metadata: [AnyObject] = []

}
