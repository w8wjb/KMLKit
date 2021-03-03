//
//  KMLTrack.swift
//  KMLKit
//
//  Created by Weston Bustraan on 3/1/21.
//

import Foundation
import CoreLocation

open class KMLTrack: KMLGeometry {

    @objc open var extrude = false
    @objc open var tessellate = false
    @objc open var coordinates: [CLLocation] = []
    @objc open var angles: [String] = []
    @objc open var extendedData: KMLExtendedData?
}

open class KMLMultiTrack: KMLGeometry {
 
    @objc open var interpolate = false
    @objc open var tracks: [KMLTrack] = []

}
