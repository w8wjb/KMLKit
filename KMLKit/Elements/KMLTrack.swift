//
//  KMLTrack.swift
//  KMLKit
//
//  Created by Weston Bustraan on 3/1/21.
//

import Foundation
import CoreLocation

public class KMLTrack: KMLGeometry {

    @objc public var extrude = false
    @objc public var tessellate = false
    @objc public var coordinates: [CLLocation] = []
    @objc public var angles: [String] = []
    @objc public var extendedData: KMLExtendedData?
}

public class KMLMultiTrack: KMLGeometry {
 
    @objc public var interpolate = false

}
