//
//  Orientation.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import CoreLocation

open class KMLOrientation: KMLObject {

    @objc open var heading = CLLocationDegrees()
    @objc open var tilt = CLLocationDegrees()
    @objc open var roll = CLLocationDegrees()

}
