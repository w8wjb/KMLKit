//
//  Region.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import MapKit

public class Region: KmlObject {

    public var latLonAltBox: LatLonAltBox?
    public var lod: Lod?
    public var metadata: [AnyObject] = []

}
