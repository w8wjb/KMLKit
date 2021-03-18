//
//  Camera.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import CoreLocation

/**
 Defines the virtual camera that views the scene. This element defines the position of the camera relative to the Earth's surface as well as the viewing direction of the camera. The camera position is defined by &lt;longitude&gt;, &lt;latitude&gt;, &lt;altitude&gt;, and either &lt;altitudeMode&gt; or &lt;gx:altitudeMode&gt;. The viewing direction of the camera is defined by &lt;heading&gt;, &lt;tilt&gt;, and &lt;roll&gt;. &lt;Camera&gt; can be a child element of any Feature or of &lt;NetworkLinkControl&gt;. A parent element cannot contain both a &lt;Camera&gt; and a &lt;LookAt&gt; at the same time.

 &lt;Camera&gt; provides full six-degrees-of-freedom control over the view, so you can position the Camera in space and then rotate it around the X, Y, and Z axes. Most importantly, you can tilt the camera view so that you're looking above the horizon into the sky.

 &lt;Camera&gt; can also contain a TimePrimitive (&lt;gx:TimeSpan&gt; or &lt;gx:TimeStamp&gt;). Time values in Camera affect historical imagery, sunlight, and the display of time-stamped features. For more information, read [Time with AbstractViews](https://developers.google.com/kml/documentation/time#abstractviews) in the **Time and Animation** chapter of the Developer's Guide.
 
 # Defining a View
 
 Within a Feature or &lt;NetworkLinkControl&gt;, use either a &lt;Camera&gt; or a &lt;LookAt&gt; object (but not both in the same object). The &lt;Camera&gt; object defines the viewpoint in terms of the viewer's position and orientation. The &lt;Camera&gt; object allows you to specify a view that is not on the Earth's surface. The &lt;LookAt&gt; object defines the viewpoint in terms of what is being viewed. The &lt;LookAt&gt; object is more limited in scope than &lt;Camera&gt; and generally requires that the view direction intersect the Earth's surface.

 The following diagram shows the X, Y, and Z axes, which are attached to the virtual camera.

 - The X axis points toward the right of the camera and is called the right vector.
 - The Y axis defines the "up" direction relative to the screen and is called the up vector.
 - The Z axis points from the center of the screen toward the eye point. The camera looks down the −Z axis, which is called the view vector.
 
 ![Default Camera Axes](https://developers.google.com/kml/documentation/images/defaultCameraAxes.gif)
 
 # Order of Transformations

 The order of rotation is important. By default, the camera is looking straight down the −Z axis toward the Earth. Before rotations are performed, the camera is translated along the Z axis to &lt;altitude&gt;. The order of transformations is as follows:

 1. &lt;altitude&gt; - translate along the Z axis to &lt;altitude&gt;
 2. &lt;heading&gt; - rotate around the Z axis.
 3. &lt;tilt&gt; - rotate around the X axis.
 4. &lt;roll&gt; - rotate around the Z axis (again).
 
 Note that each time a rotation is applied, two of the camera axes change their orientation.
 
 */
open class KMLCamera: KMLAbstractView {
    
    /** Longitude of the virtual camera (eye point). Angular distance in degrees, relative to the Prime Meridian. Values west of the Meridian range from −180 to 0 degrees. Values east of the Meridian range from 0 to 180 degrees. */
    @objc open var longitude = CLLocationDegrees()
    /** Latitude of the virtual camera. Degrees north or south of the Equator (0 degrees). Values range from −90 degrees to 90 degrees. */
    @objc open var latitude = CLLocationDegrees()
    /** Distance of the camera from the earth's surface, in meters. Interpreted according to the Camera's &lt;altitudeMode&gt; or &lt;gx:altitudeMode&gt;. */
    @objc open var altitude = CLLocationDistance()
    /** Direction (azimuth) of the camera, in degrees. Default=0 (true North). Values range from 0 to 360 degrees. */
    @objc open var heading = CLLocationDirection()
    /** Rotation, in degrees, of the camera around the X axis. A value of 0 indicates that the view is aimed straight down toward the earth (the most common case). A value for 90 for &lt;tilt&gt; indicates that the view is aimed toward the horizon. Values greater than 90 indicate that the view is pointed up into the sky. Values for &lt;tilt&gt; are clamped at +180 degrees. */
    @objc open var tilt: Double = 0
    /** Rotation, in degrees, of the camera around the Z axis. Values range from −180 to +180 degrees. */
    @objc open var roll: Double = 0
    /** Specifies how the &lt;altitude&gt; specified for the Camera is interpreted. */
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
extension KMLCamera {
    
    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "longitude", value: longitude, default: 0.0)
        addSimpleChild(to: element, withName: "latitude", value: longitude, default: 0.0)
        addSimpleChild(to: element, withName: "altitude", value: altitude, default: 0.0)
        addSimpleChild(to: element, withName: "heading", value: heading, default: 0.0)
        addSimpleChild(to: element, withName: "tilt", value: tilt, default: 0.0)
        addSimpleChild(to: element, withName: "roll", value: roll, default: 0.0)
        addSimpleChild(to: element, withName: "altitudeMode", value: altitudeMode.description, default: "clampToGround")
        addSimpleChild(to: element, withName: "horizFov", value: horizFov, default: 0.0)
    }

}
#endif
