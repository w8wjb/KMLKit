//
//  Orientation.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import CoreLocation

/**
 Describes rotation of a 3D model's coordinate system to position the object in Google Earth.
 
 Rotations are applied to a Model in the following order:

 1. &lt;roll&gt;
 2. &lt;tilt&gt;
 3. &lt;heading&gt;
 */
open class KMLOrientation: KMLObject {

    /** Rotation about the z axis (normal to the Earth's surface). A value of 0 (the default) equals North. A positive rotation is clockwise around the z axis and specified in degrees from 0 to 360. */
    @objc open var heading = CLLocationDegrees()
    /** Rotation about the x axis. A positive rotation is clockwise around the x axis and specified in degrees from 0 to 180. */
    @objc open var tilt = CLLocationDegrees()
    /** Rotation about the y axis. A positive rotation is clockwise around the y axis and specified in degrees from 0 to 180. */
    @objc open var roll = CLLocationDegrees()

}

#if os(macOS)
extension KMLOrientation {

    override func toElement(in doc: XMLDocument) -> XMLElement {
        let element = super.toElement(in: doc)
        addSimpleChild(to: element, withName: "heading", value: heading)
        addSimpleChild(to: element, withName: "tilt", value: tilt)
        addSimpleChild(to: element, withName: "roll", value: roll)
        return element
    }
}
#endif
