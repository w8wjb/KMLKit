//
//  LookAt.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import CoreLocation

/**
 Defines a virtual camera that is associated with any element derived from Feature. The LookAt element positions the "camera" in relation to the object that is being viewed. In Google Earth, the view "flies to" this LookAt viewpoint when the user double-clicks an item in the Places panel or double-clicks an icon in the 3D viewer.
 */
open class KMLLookAt: KMLAbstractView {
    /** Longitude of the point the camera is looking at. Angular distance in degrees, relative to the Prime Meridian. Values west of the Meridian range from −180 to 0 degrees. Values east of the Meridian range from 0 to 180 degrees. */
    @objc open var longitude = CLLocationDegrees()
    /** Latitude of the point the camera is looking at. Degrees north or south of the Equator (0 degrees). Values range from −90 degrees to 90 degrees. */
    @objc open var latitude = CLLocationDegrees()
    /** Distance from the earth's surface, in meters. Interpreted according to the LookAt's altitude mode. */
    @objc open var altitude = CLLocationDistance()
    /** Direction (that is, North, South, East, West), in degrees. Default=0 (North). Values range from 0 to 360 degrees.*/
    @objc open var heading = CLLocationDirection()
    /** Angle between the direction of the LookAt position and the normal to the surface of the earth. (See diagram below.) Values range from 0 to 90 degrees. Values for &lt;tilt&gt; cannot be negative. A &lt;tilt&gt; value of 0 degrees indicates viewing from directly above. A &lt;tilt&gt; value of 90 degrees indicates viewing along the horizon. */
    @objc open var tilt: Double = 0
    /** Distance in meters from the point specified by &lt;longitude&gt;, &lt;latitude&gt;, and &lt;altitude&gt; to the LookAt position. */
    @objc open var range: Double = 0
    /** Specifies how the &lt;altitude&gt; specified for the LookAt point is interpreted */
    @objc open var altitudeMode = KMLAltitudeMode.clampToGround
    
    /** Defines the horizontal field of view of the AbstractView during a tour. This element has no effect on AbstractViews outside of a tour. &lt;gx:horizFov&gt; is inserted automatically by the Google Earth client (versions 6.1+) during tour recording. Regular AbstractViews are assigned a value of 60; views within Street View are assigned a value of 85 to match the standard Street View field of view in Google Earth. Once set, the value will be applied to subsequent views, until a new value is specified. */
    @objc open var horizFov: Double = 0

    open override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "altitudeMode", let altitudeMode = value as? KMLAltitudeMode {
            self.altitudeMode = altitudeMode
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
    
}

#if os(macOS)
extension KMLLookAt {

    override func toElement(in doc: XMLDocument) -> XMLElement {
        let element = super.toElement(in: doc)
        addSimpleChild(to: element, withName: "longitude", value: longitude, default: 0)
        addSimpleChild(to: element, withName: "latitude", value: latitude, default: 0)
        addSimpleChild(to: element, withName: "altitude", value: altitude, default: 0)
        addSimpleChild(to: element, withName: "heading", value: heading, default: 0)
        addSimpleChild(to: element, withName: "tilt", value: tilt, default: 0)
        addSimpleChild(to: element, withName: "range", value: range, default: 0)
        addSimpleChild(to: element, withName: "altitudeMode", value: altitudeMode.description, default: "clampToGround")
        addSimpleChild(to: element, withName: "horizFov", value: horizFov, default: 0)
        return element
    }
}
#endif
