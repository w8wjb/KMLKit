//
//  Orientation.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import CoreLocation

public class Orientation: KmlObject {

    public var heading = CLLocationDegrees()
    public var tilt = CLLocationDegrees()
    public var roll = CLLocationDegrees()

}
