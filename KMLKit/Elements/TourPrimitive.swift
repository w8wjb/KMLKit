//
//  TourPrimitive.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class TourPrimitive: KmlObject {
    
}

public class Wait: TourPrimitive {
    public var duration: Double = 0.0
}

public class AnimatedUpdate: TourPrimitive {
    public var duration: Double = 0.0
    public var update: Update?
    public var delayedStart: Double?
}

public class TourControl: TourPrimitive {
    
    public enum PlayMode: String {
        case pause = "pause"
    }
    
    public var mode = PlayMode.pause
    
}

public class FlyTo: TourPrimitive {
    
    public enum FlyToMode: String {
        case bounce = "bounce"
        case smooth = "smooth"
    }
    
    public var duration: Double = 0.0
    public var mode = FlyToMode.bounce
    public var view: AbstractView?
}

public class SoundCue: TourPrimitive {
    
    public var href: String?
    public var delayedStart: Double = 0.0
    
}
