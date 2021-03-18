//
//  Geometry.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import MapKit

public protocol KMLGeometryCollection {
    func add(geometry: KMLGeometry)
}

/**
 This is an abstract element and cannot be used directly in a KML file. It provides a placeholder object for all derived Geometry objects.
 */
open class KMLGeometry: KMLObject {
    @objc open var altitudeMode = KMLAltitudeMode.clampToGround
    
    open override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "altitudeMode", let altitudeMode = value as? KMLAltitudeMode {
            self.altitudeMode = altitudeMode
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
}

#if os(macOS)
extension KMLGeometry {

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "altitudeMode", value: altitudeMode.description, default: "clampToGround")
    }
    
}
#endif

/**
 A geographic location defined by longitude, latitude, and (optional) altitude. When a Point is contained by a Placemark, the point itself determines the position of the Placemark's name and icon. When a Point is extruded, it is connected to the ground with a line. This "tether" uses the current LineStyle.
 */
open class KMLPoint: KMLGeometry {
    
    /** Specifies whether to connect the point to the ground with a line. To extrude a Point, the value for &lt;altitudeMode&gt; must be either **relativeToGround**, **relativeToSeaFloor**, or **absolute**. The point is extruded toward the center of the Earth's sphere. */
    @objc open var extrude = false
    
    /**
     A single tuple consisting of floating point values for longitude, latitude, and altitude (in that order).
     
     Longitude and latitude values are in degrees, where
     - longitude ≥ −180 and &lt;= 180
     - latitude ≥ −90 and ≤ 90
     - altitude values (optional) are in meters above sea level
     */
    @objc open var location = CLLocation()
    
    open override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "coordinates",
           let coordinates = value as? [CLLocation],
           let location = coordinates.first {
            self.location = location
            
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
    
}

#if os(macOS)
extension KMLPoint {

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        addSimpleChild(to: element, withName: "extrude", value: extrude, numeric: true, default: false)
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "coordinates", value: formatAsLonLatAlt(location))
    }

}
#endif

/**
 A 3D object described in a COLLADA file (referenced in the &lt;Link&gt; tag). COLLADA files have a .dae file extension. Models are created in their own coordinate space and then located, positioned, and scaled in Google Earth. See the "Topics in KML" page on [Models](https://developers.google.com/kml/documentation/models) for more detail.

 Google Earth supports the COLLADA common profile, with the following exceptions:

 - Google Earth supports only triangles and lines as primitive types. The maximum number of triangles allowed is 21845.
 - Google Earth does not support animation or skinning.
 - Google Earth does not support external geometry references.
 */
open class KMLModel: KMLGeometry {
    
    open class KMLScale: KMLObject {
        @objc open var x: Double = 1.0
        @objc open var y: Double = 1.0
        @objc open var z: Double = 1.0
    }

    /**
     Specifies the exact coordinates of the Model's origin in latitude, longitude, and altitude. Latitude and longitude measurements are standard lat-lon projection with WGS84 datum. Altitude is distance above the earth's surface, in meters, and is interpreted according to &lt;altitudeMode&gt; or &lt;gx:altitudeMode&gt;.
     */
    @objc open var location = CLLocation()
    /** Describes rotation of a 3D model's coordinate system to position the object in Google Earth. */
    @objc open var orientation = KMLOrientation()
    /** Scales a model along the x, y, and z axes in the model's coordinate space. */
    @objc open var scale = KMLScale()
    /** Specifies the file to load and optional refresh parameters */
    @objc open var link: KMLLink?
    
    /**
     Specifies 0 or more &lt;Alias&gt; elements, each of which is a mapping for the texture file path from the original Collada file to the KML or KMZ file that contains the Model. This element allows you to move and rename texture files without having to update the original Collada file that references those textures. One &lt;ResourceMap&gt; element can contain multiple mappings from different (source) Collada files into the same (target) KMZ file.

     ## &lt;Alias&gt; contains a mapping from a &lt;sourceHref&gt; to a &lt;targetHref&gt;:
     ### &lt;targetHref&gt;
     Specifies the texture file to be fetched by Google Earth. This reference can be a relative reference to an image file within the .kmz archive, or it can be an absolute reference to the file (for example, a URL).
    
     ### &lt;sourceHref&gt;
     Is the path specified for the texture file in the Collada .dae file.
     
     In Google Earth, if this mapping is not supplied, the following rules are used to locate the textures referenced in the Collada (.dae) file:
     - **No path**: If the texture name does not include a path, Google Earth looks for the texture in the same directory as the .dae file that references it.
     - **Relative path**: If the texture name includes a relative path (for example, ../images/mytexture.jpg), Google Earth interprets the path as being relative to the .dae file that references it.
     - **Absolute path**: If the texture name is an absolute path (c:\mytexture.jpg) or a network path (for example, http://myserver.com/mytexture.jpg), Google Earth looks for the file in the specified location, regardless of where the .dae file is located.
     
     */
    @objc open var resourceMap: [String:String] = [:]

}

#if os(macOS)
extension KMLModel {
    
    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        let locationElem = XMLElement(name: "Location")
        addSimpleChild(to: locationElem, withName: "longitude", value: location.coordinate.longitude)
        addSimpleChild(to: locationElem, withName: "latitude", value: location.coordinate.latitude)
        addSimpleChild(to: locationElem, withName: "altitude", value: location.altitude)
        element.addChild(locationElem)
        
        addChild(to: element, child: orientation, in: doc)
        addChild(to: element, child: scale, in: doc)
        addChild(to: element, child: link, in: doc)
        
        
        if !resourceMap.isEmpty {
            let resourceMapElem = XMLElement(name: "ResourceMap")
            for (key, value) in resourceMap {
                let aliasElem = XMLElement(name: "Alias")
                addSimpleChild(to: aliasElem, withName: "targetHref", value: value)
                addSimpleChild(to: aliasElem, withName: "sourceHref", value: key)
                resourceMapElem.addChild(aliasElem)
            }
            element.addChild(resourceMapElem)
        }
    }

}

extension KMLModel.KMLScale {
    
    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "x", value: x)
        addSimpleChild(to: element, withName: "y", value: y)
        addSimpleChild(to: element, withName: "z", value: z)
    }
    
}

#endif

/**
 A container for zero or more geometry primitives associated with the same feature.
 */
open class KMLMultiGeometry: KMLGeometry, KMLGeometryCollection {

    @objc open var geometry: [KMLGeometry] = []

    open func add(geometry: KMLGeometry) {
        self.geometry.append(geometry)
    }
}

#if os(macOS)
extension KMLMultiGeometry {

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        for child in geometry {
            addChild(to: element, child: child, in: doc)
        }
    }

}
#endif

/**
 Defines a connected set of line segments. Use &lt;LineStyle&gt; to specify the color, color mode, and width of the line. When a LineString is extruded, the line is extended to the ground, forming a polygon that looks somewhat like a wall or fence. For extruded LineStrings, the line itself uses the current LineStyle, and the extrusion uses the current PolyStyle. See the [KML Tutorial](https://developers.google.com/kml/documentation/kml_tut) for examples of LineStrings (or paths).
 */
open class KMLLineString: KMLGeometry {
    /** Specifies whether to connect the LineString to the ground. To extrude a LineString, the altitude mode must be either **relativeToGround**, **relativeToSeaFloor**, or **absolute**. The vertices in the LineString are extruded toward the center of the Earth's sphere. */
    @objc open var extrude = false
    
    /** Specifies whether to allow the LineString to follow the terrain. To enable tessellation, the altitude mode must be **clampToGround** or **clampToSeaFloor**. Very large LineStrings should enable tessellation so that they follow the curvature of the earth (otherwise, they may go underground and be hidden). */
    @objc open var tessellate = false
    /** Two or more coordinate tuples, each consisting of floating point values for longitude, latitude, and altitude. The altitude component is optional. Insert a space between tuples. Do not include spaces within a tuple. */
    @objc open var coordinates: [CLLocation] = []
    @objc open var altitudeOffset: Double = 0.0
}

#if os(macOS)
extension KMLLineString {

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        addSimpleChild(to: element, withName: "extrude", value: extrude, numeric: true, default: false)
        addSimpleChild(to: element, withName: "tessellate", value: tessellate, numeric: true, default: false)
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "coordinates", value: formatAsLonLatAlt(coordinates))
        addSimpleChild(to: element, withName: "altitudeOffset", value: altitudeOffset, default: 0.0)
    }
    
}
#endif

/**
 Defines a closed line string, typically the outer boundary of a Polygon. Optionally, a LinearRing can also be used as the inner boundary of a Polygon to create holes in the Polygon. A Polygon can contain multiple &lt;LinearRing&gt; elements used as inner boundaries.
 */
open class KMLLinearRing: KMLGeometry {
    /** Specifies whether to connect the LinearRing to the ground. To extrude this geometry, the altitude mode must be either **relativeToGround**, **relativeToSeaFloor**, or **absolute**. Only the vertices of the LinearRing are extruded, not the center of the geometry. The vertices are extruded toward the center of the Earth's sphere. */
    @objc open var extrude = false
    /** Specifies whether to allow the LinearRing to follow the terrain. To enable tessellation, the value for &lt;altitudeMode&gt; must be **clampToGround** or **clampToSeaFloor**. Very large LinearRings should enable tessellation so that they follow the curvature of the earth (otherwise, they may go underground and be hidden). */
    @objc open var tessellate = false
    
    /** Four or more tuples, each consisting of floating point values for longitude, latitude, and altitude. The altitude component is optional. Do not include spaces within a tuple. The last coordinate must be the same as the first coordinate. Coordinates are expressed in decimal degrees only. */
    @objc open var coordinates: [CLLocation] = []
}

#if os(macOS)
extension KMLLinearRing {
    
    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "extrude", value: extrude, numeric: true, default: false)
        addSimpleChild(to: element, withName: "tessellate", value: tessellate, numeric: true, default: false)
        addSimpleChild(to: element, withName: "coordinates", value: formatAsLonLatAlt(coordinates))
    }

}
#endif

open class KMLBoundary: NSObject {
    @objc open var linearRing = KMLLinearRing()
}

/**
 A Polygon is defined by an outer boundary and 0 or more inner boundaries. The boundaries, in turn, are defined by LinearRings. When a Polygon is extruded, its boundaries are connected to the ground to form additional polygons, which gives the appearance of a building or a box. Extruded Polygons use &lt;PolyStyle&gt; for their color, color mode, and fill.

 The &lt;coordinates&gt; for polygons must be specified in counterclockwise order. Polygons follow the "right-hand rule," which states that if you place the fingers of your right hand in the direction in which the coordinates are specified, your thumb points in the general direction of the geometric normal for the polygon. (In 3D graphics, the geometric normal is used for lighting and points away from the front face of the polygon.) Since Google Earth fills only the front face of polygons, you will achieve the desired effect only when the coordinates are specified in the proper order. Otherwise, the polygon will be gray.
 */
open class KMLPolygon: KMLGeometry {

    /** Specifies whether to connect the Polygon to the ground. To extrude a Polygon, the altitude mode must be either **relativeToGround**, **relativeToSeaFloor**, or **absolute**. Only the vertices are extruded, not the geometry itself (for example, a rectangle turns into a box with five faces. The vertices of the Polygon are extruded toward the center of the Earth's sphere. */
    @objc open var extrude = false
    /** This field is not used by Polygon. To allow a Polygon to follow the terrain (that is, to enable tessellation) specify an altitude mode of **clampToGround** or **clampToSeaFloor**. */
    @objc open var tessellate = false
    /** Contains a &lt;LinearRing&gt; element. */
    @objc open var outerBoundaryIs = KMLBoundary()
    /** Contains a &lt;LinearRing&gt; element. A Polygon can contain multiple &lt;innerBoundaryIs&gt; elements, which create multiple cut-outs inside the Polygon. */
    @objc open var innerBoundaryIs: [KMLBoundary] = []
}

#if os(macOS)
extension KMLPolygon {
    
    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        addSimpleChild(to: element, withName: "extrude", value: extrude, numeric: true, default: false)
        addSimpleChild(to: element, withName: "tessellate", value: tessellate, numeric: true, default: false)
        super.addChildNodes(to: element, in: doc)

        
        let outerBoundaryIsElem = XMLElement(name: "outerBoundaryIs")
        addChild(to: outerBoundaryIsElem, child: outerBoundaryIs.linearRing, in: doc)
        element.addChild(outerBoundaryIsElem)
        
        for child in innerBoundaryIs {
            let innerBoundaryIsElem = XMLElement(name: "innerBoundaryIs")
            addChild(to: innerBoundaryIsElem, child: child.linearRing, in: doc)
            element.addChild(innerBoundaryIsElem)
        }
        
    }

}
#endif
