//
//  AltitudeMode.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

/**
 Altitude Mode
 
 &lt;altitudeMode&gt; affects:
 - the altitude coordinate within the &lt;coordinates&gt; element
 - &lt;minAltitude&gt; and &lt;maxAltitude&gt; within &lt;LatLonAltBox&gt;
 - &lt;altitude&gt; within &lt;Location&gt;, &lt;GroundOverlay&gt;, and AbstractView (&lt;LookAt&gt; and &lt;Camera&gt;).
 
 - SeeAlso: More information about altitude modes is available in the [Altitude Modes](https://developers.google.com/kml/documentation/altitudemode) chapter of the KML Developer's Guide.
 */
@objc public enum KMLAltitudeMode: Int, CustomStringConvertible {
    /** For a camera, this setting also places the camera **relativeToGround**, since putting the camera exactly at terrain height would mean that the eye would intersect the terrain (and the view would be blocked). */
    case clampToGround
    /** (default) Interprets the &lt;altitude&gt; as a value in meters above the ground. If the point is over water, the &lt;altitude&gt; will be interpreted as a value in meters above sea level. See &lt;gx:altitudeMode&gt; below to specify points relative to the sea floor. */
    case relativeToGround
    /** Interprets the &lt;altitude&gt; as a value in meters above sea level. */
    case absolute
    /** The altitude specification is ignored, and the KML feature will be positioned on the sea floor. If the KML feature is on land rather than at sea, **clampToSeaFloor** will instead clamp to ground. */
    case clampToSeaFloor
    /** Interprets the altitude as a value in meters above the sea floor. If the KML feature is above land rather than sea, the altitude will be interpreted as being above the ground. */
    case relativeToSeaFloor
    
    public init(_ value: String) {
        switch value {
        case "clampToGround":
            self = .clampToGround
        case "relativeToGround":
            self = .relativeToGround
        case "absolute":
            self = .absolute
        case "clampToSeaFloor":
            self = .clampToSeaFloor
        case "relativeToSeaFloor":
            self = .relativeToSeaFloor
        default:
            self = .clampToGround
        }
    }
    
    public var elementName: String {
        switch self {
        case .relativeToSeaFloor, .clampToSeaFloor:
            return "gx:altitudeMode"
        default:
            return "altitudeMode"
        }
    }
    
    public var description: String {
        switch self {
        case .clampToGround:
            return "clampToGround"
        case .relativeToGround:
            return "relativeToGround"
        case .absolute:
            return "absolute"
        case .clampToSeaFloor:
            return "clampToSeaFloor"
        case .relativeToSeaFloor:
            return "relativeToSeaFloor"
        }
    }
}

@objc public enum KMLSeaFloorAltitudeMode: Int, CustomStringConvertible {
    case clampToSeaFloor
    case relativeToSeaFloor
    
    public init(_ value: String) {
        switch value {
        case "clampToSeaFloor":
            self = .clampToSeaFloor
        case "relativeToSeaFloor":
            self = .relativeToSeaFloor
        default:
            self = .clampToSeaFloor
        }
    }
    
    public var description: String {
        switch self {
        case .clampToSeaFloor:
            return "clampToSeaFloor"
        case .relativeToSeaFloor:
            return "relativeToSeaFloor"
        }
    }
}
