//
//  Overlay.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import CoreLocation
import MapKit

open class KMLOverlay: KMLFeature {

    @objc open var color: KMLColor?
    @objc open var drawOrder = 0
    @objc open var icon: KMLIcon?
    
}

open class KMLGroundOverlay: KMLOverlay {
    
    @objc open var altitude: CLLocationDistance = 0.0
    @objc open var altitudeMode = KMLAltitudeMode.clampToGround
    @objc open var extent: KMLAbstractExtent?
    
    open override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "altitudeMode", let altitudeMode = value as? KMLAltitudeMode {
            self.altitudeMode = altitudeMode
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
}

open class KMLPhotoOverlay: KMLOverlay {
    
    open class ViewVolume: NSObject {
        @objc var leftFov: Double = 0.0
        @objc var rightFov: Double = 0.0
        @objc var bottomFov: Double = 0.0
        @objc var topFov: Double = 0.0
        @objc var near: Double = 0.0
    }
    
    @objc public enum GridOrigin: Int {
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
    
    
    open class ImagePyramid: NSObject {
        @objc open var tileSize = 256
        @objc open var maxWidth = 0
        @objc open var maxHeight = 0
        @objc open var gridOrigin = GridOrigin.lowerLeft
        
        open override func setValue(_ value: Any?, forKey key: String) {
            
            if key == "gridOrigin", let gridOrigin = value as? GridOrigin {
                self.gridOrigin = gridOrigin
            } else {
                super.setValue(value, forKey: key)
            }
            
        }
    }
    
    @objc public enum Shape: Int {
        case rectangle
        case cylinder
        case sphere
        
        init(_ value: String) {
            switch value {
            case "rectangle":
                self = .rectangle
            case "cylinder":
                self = .cylinder
            case "sphere":
                self = .sphere
            default:
                self = .rectangle
            }
        }
    }
    

    @objc open var rotation: Double = 0.0
    @objc open var viewVolume: ViewVolume?
    @objc open var imagePyramid: ImagePyramid?
    @objc open var point: KMLPoint?
    @objc open var shape = Shape.rectangle
    
    open override func setValue(_ value: Any?, forKey key: String) {        
        if key == "shape", let shape = value as? Shape {
            self.shape = shape
        } else {
            super.setValue(value, forKey: key)
        }
    }
}

open class KMLScreenOverlay: KMLOverlay {
    open var overlayXY: CGPoint?
    open var screenXY: CGPoint?
    open var rotationXY: CGPoint?
    open var size: CGSize?
    @objc open var rotation: Double = 0
    
    open override func setValue(_ value: Any?, forKey key: String) {
        
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
