//
//  TourPrimitive.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class KMLTourPrimitive: KMLObject {
    
}

public class Wait: KMLTourPrimitive {
    @objc public var duration: Double = 0.0
}

public class AnimatedUpdate: KMLTourPrimitive {
    @objc public var duration: Double = 0.0
    @objc public var update: KMLUpdate?
    @objc public var delayedStart: Double = 0.0
}

public class TourControl: KMLTourPrimitive {
    
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
    
    @objc public var mode = PlayMode.pause
    
}

public class FlyTo: KMLTourPrimitive {
    
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
    
    @objc public var duration: Double = 0.0
    @objc public var mode = FlyToMode.bounce
    @objc public var view: KMLAbstractView?
    
    public override func setValue(_ value: Any?, forKey key: String) {        
        if key == "flyToMode", let mode = value as? FlyToMode {
            self.mode = mode
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
}

public class SoundCue: KMLTourPrimitive {
    
    @objc public var href: String?
    @objc public var delayedStart: Double = 0.0
    
}
