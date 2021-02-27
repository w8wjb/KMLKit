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
    public var duration: Double = 0.0
}

public class AnimatedUpdate: KMLTourPrimitive {
    public var duration: Double = 0.0
    public var update: KMLUpdate?
    public var delayedStart: Double?
}

public class TourControl: KMLTourPrimitive {
    
    public enum PlayMode: String {
        case pause = "pause"
    }
    
    public var mode = PlayMode.pause
    
}

public class FlyTo: KMLTourPrimitive {
    
    public enum FlyToMode: String {
        case bounce = "bounce"
        case smooth = "smooth"
    }
    
    public var duration: Double = 0.0
    public var mode = FlyToMode.bounce
    public var view: KMLAbstractView?
}

public class SoundCue: KMLTourPrimitive {
    
    public var href: String?
    public var delayedStart: Double = 0.0
    
}
