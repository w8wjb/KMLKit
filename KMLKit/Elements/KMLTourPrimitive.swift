//
//  TourPrimitive.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public protocol KMLTourPrimitiveDuration {
    var duration: Double { get set }
}

open class KMLTourPrimitive: KMLObject {
    
}

open class KMLTourWait: KMLTourPrimitive, KMLTourPrimitiveDuration {
    @objc open var duration: Double = 0.0
}

open class KMLTourAnimatedUpdate: KMLTourPrimitive, KMLTourPrimitiveDuration {
    @objc open var duration: Double = 0.0
    @objc open var update: KMLUpdate?
    @objc open var delayedStart: Double = 0.0
}

open class KMLTourControl: KMLTourPrimitive {
    
    @objc public enum PlayMode: Int {
        case pause
        
        init(_ value: String) {
            switch value {
            case "pause":
                self = .pause
            default:
                self = .pause
            }
        }
    }
    
    @objc open var mode = PlayMode.pause
 
    open override func setValue(_ value: Any?, forKey key: String) {
        if key == "playMode", let mode = value as? PlayMode {
            self.mode = mode
        } else {
            super.setValue(value, forKey: key)
        }
    }
}

open class KMLTourFlyTo: KMLTourPrimitive, KMLTourPrimitiveDuration {
    
    @objc public enum FlyToMode: Int {
        case bounce
        case smooth
        
        init(_ value: String) {
            switch value {
            case "bounce":
                self = .bounce
            case "smooth":
                self = .smooth
            default:
                self = .bounce
            }
        }
    }
    
    @objc open var duration: Double = 0.0
    @objc open var mode = FlyToMode.bounce
    @objc open var view: KMLAbstractView?
    
    open override func setValue(_ value: Any?, forKey key: String) {        
        if key == "flyToMode", let mode = value as? FlyToMode {
            self.mode = mode
        } else {
            super.setValue(value, forKey: key)
        }
    }
}

open class KMLTourSoundCue: KMLTourPrimitive {
    
    @objc open var href: URL?
    @objc open var delayedStart: Double = 0.0
    
}
