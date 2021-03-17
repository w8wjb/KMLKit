//
//  LatLonBox.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/26/21.
//

import Foundation
import CoreLocation

open class KMLAbstractExtent: KMLObject {
    
}

open class KMLAbstractLatLonBox: KMLAbstractExtent {
    /** Specifies the latitude of the north edge of the bounding box, in decimal degrees from 0 to ±90. */
    @objc open var north: CLLocationDegrees = 0
    /** Specifies the latitude of the south edge of the bounding box, in decimal degrees from 0 to ±90. */
    @objc open var south: CLLocationDegrees = 0
    /** Specifies the longitude of the east edge of the bounding box, in decimal degrees from 0 to ±180. (For overlays that overlap the meridian of 180° longitude, values can extend beyond that range.) */
    @objc open var east: CLLocationDegrees = 0
    /** Specifies the longitude of the west edge of the bounding box, in decimal degrees from 0 to ±180. (For overlays that overlap the meridian of 180° longitude, values can extend beyond that range.) */
    @objc open var west: CLLocationDegrees = 0
}

#if os(macOS)
extension KMLAbstractLatLonBox {

    override func toElement(in doc: XMLDocument) -> XMLElement {
        let element = super.toElement(in: doc)
        addSimpleChild(to: element, withName: "north", value: north)
        addSimpleChild(to: element, withName: "south", value: south)
        addSimpleChild(to: element, withName: "east", value: east)
        addSimpleChild(to: element, withName: "west", value: west)
        return element
    }
}
#endif

/**
 Specifies where the top, bottom, right, and left sides of a bounding box for the ground overlay are aligned.
 */
open class KMLLatLonBox: KMLAbstractLatLonBox {
    /** Specifies a rotation of the overlay about its center, in degrees. Values can be ±180. The default is 0 (north). Rotations are specified in a counterclockwise direction. */
    @objc open var rotation: CLLocationDegrees = 0.0
}

#if os(macOS)
extension KMLLatLonBox {

    override func toElement(in doc: XMLDocument) -> XMLElement {
        let element = super.toElement(in: doc)
        addSimpleChild(to: element, withName: "rotation", value: rotation, default: 0.0)
        return element
    }
}
#endif

open class KMLLatLonAltBox: KMLAbstractLatLonBox {
    
    /** Specified in meters (and is affected by the altitude mode specification). */
    @objc open var minAltitude: CLLocationDistance = 0.0
    /** Specified in meters (and is affected by the altitude mode specification). */
    @objc open var maxAltitude: CLLocationDegrees = 0.0    
    @objc open var altitudeMode = KMLAltitudeMode.clampToGround
    @objc open var seaFloorAltitudeMode = KMLSeaFloorAltitudeMode.clampToSeaFloor
    
    open override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "altitudeMode", let altitudeMode = value as? KMLAltitudeMode {
            self.altitudeMode = altitudeMode
        } else if key == "seaFloorAltitudeMode", let seaFloorAltitudeMode = value as? KMLSeaFloorAltitudeMode {
                self.seaFloorAltitudeMode = seaFloorAltitudeMode
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
    
}

#if os(macOS)
extension KMLLatLonAltBox {

    override func toElement(in doc: XMLDocument) -> XMLElement {
        let element = super.toElement(in: doc)
        addSimpleChild(to: element, withName: "minAltitude", value: minAltitude, default: 0.0)
        addSimpleChild(to: element, withName: "maxAltitude", value: maxAltitude, default: 0.0)
        addSimpleChild(to: element, withName: "altitudeMode", value: altitudeMode.description, default: "clampToGround")
        addSimpleChild(to: element, withName: "seaFloorAltitudeMode", value: seaFloorAltitudeMode.description, default: "clampToSeaFloor")
        return element
    }
}
#endif

/**
 Used for nonrectangular quadrilateral ground overlays.
 
 Allows nonrectangular quadrilateral ground overlays.

 Specifies the coordinates of the four corner points of a quadrilateral defining the overlay area. Exactly four coordinate tuples have to be provided, each consisting of floating point values for longitude and latitude. Insert a space between tuples. Do not include spaces within a tuple. The coordinates must be specified in counter-clockwise order with the first coordinate corresponding to the lower-left corner of the overlayed image. The shape described by these corners must be convex.

 If a third value is inserted into any tuple (representing altitude) it will be ignored. Altitude is set using &lt;altitude&gt; and &lt;altitudeMode&gt; (or &lt;gx:altitudeMode&gt;) extending &lt;GroundOverlay&gt;. Allowed altitude modes are absolute, clampToGround, and clampToSeaFloor.
 */
open class KMLLatLonQuad: KMLAbstractExtent {
    @objc open var coordinates: [CLLocation] = []
}

#if os(macOS)
extension KMLLatLonQuad {

    override func toElement(in doc: XMLDocument) -> XMLElement {
        let element = super.toElement(in: doc)
        addSimpleChild(to: element, withName: "coordinates", value: formatAsLonLatAlt(coordinates))
        return element
    }
}
#endif
