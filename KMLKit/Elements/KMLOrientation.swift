//
//  Orientation.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import CoreLocation

public class KMLOrientation: KMLObject {

    @objc public var heading = CLLocationDegrees()
    @objc public var tilt = CLLocationDegrees()
    @objc public var roll = CLLocationDegrees()

}
