//
//  KMLTrack.swift
//  KMLKit
//
//  Created by Weston Bustraan on 3/1/21.
//

import Foundation
import CoreLocation

/**
 A *track* describes how an object moves through the world over a given time period.
 
 This feature allows you to create one visible object in Google Earth (either a Point icon or a Model) that encodes multiple positions for the same object for multiple times. In Google Earth, the time slider allows the user to move the view through time, which animates the position of the object.

 A gx:MultiTrack element is used to collect multiple tracks into one conceptual unit with one associated icon (or Model) that moves along the track. This feature is useful if you have multiple tracks for the same real-world object. The &lt;gx:interpolate&gt; Boolean element of a &lt;gx:MultiTrack&gt; specifies whether to interpolate between the tracks in a multi-track. If this value is 0, then the point or Model stops at the end of one track and jumps to the start of the next one. (For example, if you want a single placemark to represent your travels on two days, and your GPS unit was turned off for four hours during this period, you would want to show a discontinuity between the points where the unit was turned off and then on again.) If the value for &lt;gx:interpolate&gt; is 1, the values between the end of the first track and the beginning of the next track are interpolated so that the track appears as one continuous path.

 See the Google Earth User Guide for information on how to import GPS data into Google Earth.

 # Why are tracks useful?

 Earlier versions of KML (pre–Google Earth 5.2) allow you to associate a time element with any Feature (placemark, ground overlay, etc.). However, you could only associate one time element with a given Feature. Tracks are a more efficient mechanism for associating time data with visible Features, since you create only one Feature, which can be associated with multiple time elements as the object moves through space.

 In addition, the track element is more powerful than the earlier mechanism (described in the Time and Animation chapter of the KML Developer's Guide) because &lt;Track&gt; provides a mechanism for interpolating the position of the object at any time along its track. With this new feature, Google Earth displays a graph of elevation and speed profiles (plus custom data, if present) for the object over time.

 # "Sparse" Data

 When some data values are missing for positions on the track, empty &lt;coord/&gt; (&lt;coord&gt;&lt;/coord&gt;) or &lt;angles/&gt; (&lt;angles&gt;&lt;/angles&gt;) tags can be provided to balance the arrays. An empty &lt;coord/&gt; or &lt;angles/&gt; tag indicates that no such data exists for a given data point, and the value should be interpolated between the nearest two well-specified data points. This behavior also applies to ExtendedData for a track. Any element except &lt;when&gt; can be empty and will be interpolated between the nearest two well-specified elements.
 */
open class KMLTrack: KMLGeometry {

    @objc open var extrude = false
    @objc open var tessellate = false
    @objc open var coordinates: [CLLocation] = []
    /**
     This value is used to specify an additional heading, tilt, and roll value to the icon or model for each time/position within the track.
     
     The three floating point values are listed without comma separators and represent degrees of rotation. If &lt;gx:angles&gt; is not specified, then Google Earth infers the heading, tilt, and roll of the object from its track. The number of &lt;gx:angles&gt; elements specified should equal the number of time (&lt;when&gt;) and position (&lt;gx:coord&gt;) elements. You can specify an empty &lt;gx:angles&gt; element for a missing value if necessary.
     
     Currently, icons support only heading, but models support all three values.
     
     Here is an example of setting this value:

     ```
     <gx:angles>45.54676 66.2342 77.0</gx:angles>
     ```
     */
    @objc open var angles: [String] = []
    
    /**
     If specified, the Model replaces the Point icon used to indicate the current position on the track.
     
     When a &lt;Model&gt; is specified within a &lt;gx:Track&gt;, here is how the child elements of &lt;Model&gt; function:
     
     - The &lt;Location&gt; element is ignored.
     - The &lt;altitudeMode&gt; element is ignored.
     - The &lt;Orientation&gt; value is combined with the orientation of the track as follows. First, the &lt;Orientation&gt; rotation is applied, which brings the model from its local (x, y, z) coordinate system to a right-side-up, north-facing orientation. Next, a rotation is applied that corresponds to the interpolation of the &lt;gx:angles&gt; values that affect the heading, tilt, and roll of the model as it moves along the track. If no angles are specified, the heading and tilt are inferred from the movement of the model.
     
        Tip: If you are unsure of how to specify the orientation, omit the &lt;Orientation&gt; element from the &lt;Model&gt; and watch how Google Earth positions the model as it moves along the track. If you notice that the front of the model is facing sideways, modify the &lt;heading&gt; element in &lt;Orientation&gt; to rotate the model so that it points toward the front. If the model is not upright, try modifying the &lt;tilt&gt; or &lt;roll&gt; elements.

     */
    @objc open var model: KMLModel?
    
    /**
     Custom data elements defined in a &lt;Schema&gt; earlier in the KML file.

     It's often useful to add extended data associated with each time/position on a track. Bicycle rides, for example, could include data for heart rate, cadence, and power, as shown in [Example of Track with Extended Data](https://developers.google.com/kml/documentation/kmlreference#trackexample). In the &lt;Schema&gt;, you define a &lt;gx:SimpleArrayField&gt; for each custom data type. Then, for each data type, include a &lt;gx:SimpleArrayData&gt; element containing &lt;gx:value&gt; elements that correspond to each time/position on the track. See the [Adding Custom Data chapter](https://developers.google.com/kml/documentation/extendeddata) of the KML Developer's Guide for more information on adding new data fields. In Google Earth, custom data is displayed in the Elevation Profile for the track.
     */
    @objc open var extendedData: KMLExtendedData?
}

#if os(macOS)
extension KMLTrack {
    
    override class var elementName: String { "gx:Track" }

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "extrude", value: extrude, default: false)
        addSimpleChild(to: element, withName: "tessellate", value: tessellate, default: false)
        
        for coord in coordinates {
            addSimpleChild(to: element, withName: "when", value: coord.timestamp)
        }
        
        for coord in coordinates {
            addSimpleChild(to: element, withName: "gx:coord", value: formatAsLonLatAlt(coord))
        }
        
        for angle in angles {
            addSimpleChild(to: element, withName: "gx:angles", value: angle)
        }
        addChild(to: element, child: model, in: doc)
        addChild(to: element, child: extendedData, in: doc)
    }
}
#endif

/**
 A multi-track element is used to combine multiple track elements into a single conceptual unit.
 
 For example, suppose you collect GPS data for a day's bike ride that includes several rest stops and a stop for lunch. Because of the interruptions in time, one bike ride might appear as four different tracks when the times and positions are plotted. Grouping these &lt;gx:Track&gt; elements into one &lt;gx:MultiTrack&gt; container causes them to be displayed in Google Earth as sections of a single path. When the icon reaches the end of one segment, it moves to the beginning of the next segment. The &lt;gx:interpolate&gt; element specifies whether to stop at the end of one track and jump immediately to the start of the next one, or to interpolate the missing values between the two tracks
 */
open class KMLMultiTrack: KMLGeometry {
 
    /**  If the multi-track contains multiple &lt;gx:Track&gt; elements, specifies whether to interpolate missing values between the end of the first track and the beginning of the next one. When the default value (0) is used, the icon or model stops at the end of one track and then jumps to the start of the next one. */
    @objc open var interpolate = false
    @objc open var tracks: [KMLTrack] = []

}

#if os(macOS)
extension KMLMultiTrack {

    override class var elementName: String { "gx:MultiTrack" }
    
    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "gx:interpolate", value: interpolate, default: false)
        for track in tracks {
            addChild(to: element, child: track, in: doc)
        }
    }
}
#endif
