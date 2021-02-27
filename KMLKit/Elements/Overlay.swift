//
//  Overlay.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import CoreLocation
import MapKit

public class Overlay: Feature {

    public var color: KmlColor?
    public var drawOrder = 0
    public var icon: Icon?
    
}

public class GroundOverlay: Overlay {
    
    public var altitude: CLLocationDistance = 0.0
    public var altitudeMode = AltitudeMode.clampToGround
    public var latLonBox: LatLonBox?
    
}

public class PhotoOverlay: Overlay {
    
    public struct ViewVolume {
        var leftFov: Double = 0.0
        var rightFov: Double = 0.0
        var bottomFov: Double = 0.0
        var topFov: Double = 0.0
        var near: Double = 0.0
    }
    
    public enum GridOrigin: String {
        case lowerLeft = "lowerLeft"
        case upperLeft = "upperLeft"
    }
    
    
    public struct ImagePyramid {
        var tileSize = 256
        var maxWidth = 0
        var maxHeight = 0
        var gridOrigin = GridOrigin.lowerLeft
    }
    

    public var rotation: Double = 0.0
    public var viewVolume = ViewVolume()
    public var imagePyramid = ImagePyramid()
    
}

public class ScreenOverlay: Overlay {
    public var overlayXY: CGPoint?
    public var screenXY: CGPoint?
    public var rotationXY: CGPoint?
    public var size: CGSize?
    public var rotation: Double = 0
}
