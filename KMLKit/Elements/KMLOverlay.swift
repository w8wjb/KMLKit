//
//  Overlay.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import CoreLocation
import MapKit

public class KMLOverlay: KMLFeature {

    @objc public var color: KMLColor?
    @objc public var drawOrder = 0
    @objc public var icon: KMLIcon?
    
}

public class KMLGroundOverlay: KMLOverlay {
    
    @objc public var altitude: CLLocationDistance = 0.0
    @objc public var altitudeMode = KMLAltitudeMode.clampToGround
    @objc public var latLonBox: KMLLatLonBox?
    @objc public var extent: KMLAbstractExtent?

    
    public override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "altitudeMode", let altitudeMode = value as? KMLAltitudeMode {
            self.altitudeMode = altitudeMode
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
}

public class KMLPhotoOverlay: KMLOverlay {
    
    public class KMLViewVolume: NSObject {
        @objc var leftFov: Double = 0.0
        @objc var rightFov: Double = 0.0
        @objc var bottomFov: Double = 0.0
        @objc var topFov: Double = 0.0
        @objc var near: Double = 0.0
    }
    
    @objc public enum KMLGridOrigin: Int {
        case lowerLeft
        case upperLeft
        
        init(_ value: String) {
            switch value {
            case "lowerLeft":
                self = .lowerLeft
            case "upperLeft":
                self = .upperLeft
            default:
                self = .lowerLeft
            }
        }
    }
    
    
    public class KMLImagePyramid: NSObject {
        @objc var tileSize = 256
        @objc var maxWidth = 0
        @objc var maxHeight = 0
        @objc var gridOrigin = KMLGridOrigin.lowerLeft
    }
    

    @objc public var rotation: Double = 0.0
    @objc public var viewVolume = KMLViewVolume()
    @objc public var imagePyramid = KMLImagePyramid()
    
}

public class KMLScreenOverlay: KMLOverlay {
    public var overlayXY: CGPoint?
    public var screenXY: CGPoint?
    public var rotationXY: CGPoint?
    public var size: CGSize?
    @objc public var rotation: Double = 0
    
    public override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "overlayXY", let overlayXY = value as? CGPoint {
            self.overlayXY = overlayXY
        } else if key == "screenXY", let screenXY = value as? CGPoint {
            self.screenXY = screenXY
        } else if key == "rotationXY", let rotationXY = value as? CGPoint {
            self.rotationXY = rotationXY
        } else if key == "size", let size = value as? CGSize {
            self.size = size
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
}
