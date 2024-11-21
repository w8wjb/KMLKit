//
//  TourPrimitive.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

/**
 &lt;gx:duration&gt; extends gx:TourPrimitive by specifying a time-span for events. The time is written as seconds using XML's double datatype.

 */
public protocol KMLTourPrimitiveDuration {
    var duration: Double { get set }
}

/**
 This is an abstract element and cannot be used directly in a KML file. This element is extended by the &lt;gx:FlyTo&gt;, &lt;gx:AnimatedUpdate&gt;, &lt;gx:TourControl&gt;, &lt;gx:Wait&gt;, and &lt;gx:SoundCue&gt; elements.

 Elements extended from gx:TourPrimitive provide instructions to KML browsers during [tours](https://developers.google.com/kml/documentation/touring), including points to fly to and the duration of those flights, pauses, updates to KML features, and sound files to play.

 These elements must be contained within a &lt;gx:Playlist&gt; element, which in turn is contained with a &lt;gx:Tour&gt; element.
 */
open class KMLTourPrimitive: KMLObject {
    
}

/**
 The camera remains still, at the last-defined gx:AbstractView, for the number of seconds specified before playing the next gx:TourPrimitive. Note that a wait does not pause the tour timeline - currently-playing sound files and animated updates will continue to play while the camera is waiting.
 */
open class KMLTourWait: KMLTourPrimitive, KMLTourPrimitiveDuration {
    @objc open var duration: Double = 0.0
}

#if os(macOS)
extension KMLTourWait {

    override class var elementName: String { "gx:Wait" }
    
    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "gx:duration", value: duration, default: 0.0)
    }
}
#endif

/**
 &lt;gx:AnimatedUpdate&gt; controls changes during a tour to KML features, using `<Update>`. Changes to KML features will not modify the DOM - that is, any changes will be reverted when the tour is over, and will not be saved in the KML at any time.

 &lt;gx:AnimatedUpdate&gt; should also contain a &lt;gx:duration&gt; value to specify the length of time in seconds over which the update takes place. Integer, float, and color fields are smoothly animated from original to new value across the duration; boolean, string, and other values that don't lend to interpolation are updated at the end of the duration.

 Refer to [Tour timelines](https://developers.google.com/kml/documentation/touring#tourtimelines) in the Touring chapter of the KML Developer's Guide for information about &lt;gx:AnimatedUpdate&gt; and the tour timeline.
 
 # Duration and &lt;gx:AnimatedUpdate&gt;

 Specifies the length of time over which the update takes place. Integer, float, and color fields are smoothly animated from original to new value across the duration; boolean, string, and other values that don't lend to interpolation are updated at the end of the duration.
 */
open class KMLTourAnimatedUpdate: KMLTourPrimitive, KMLTourPrimitiveDuration {
    /** Specifies the length of time, in seconds, over which the update takes place. */
    @objc open var duration: Double = 0.0
    @objc open var update: KMLUpdate?
    /** Specifies the number of seconds to wait (after the inline start position) before starting the update. */
    @objc open var delayedStart: Double = 0.0
}

#if os(macOS)
extension KMLTourAnimatedUpdate {

    override class var elementName: String { "gx:AnimatedUpdate" }

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "gx:duration", value: duration, default: 0.0)
        addChild(to: element, child: update, in: doc)
        addSimpleChild(to: element, withName: "gx:delayedStart", value: delayedStart, default: 0.0)
    }
}
#endif

/**
 Contains a single &lt;gx:playMode&gt; element, allowing the tour to be paused until a user takes action to continue the tour.
 */
open class KMLTourControl: KMLTourPrimitive {
    
    @objc public enum PlayMode: Int, CustomStringConvertible {

        case pause
        
        init(_ value: String) {
            switch value {
            case "pause":
                self = .pause
            default:
                self = .pause
            }
        }
        
        public var description: String {
            switch self {
            case .pause:
                return "pause"
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

#if os(macOS)
extension KMLTourControl {
    
    override class var elementName: String { "gx:TourControl" }

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "gx:playMode", value: mode.description)
    }
}
#endif

/**
 &lt;gx:FlyTo&gt; specifies a point in space to which the browser will fly during a tour. It must contain one AbstractView, and should contain &lt;gx:duration&gt; and &lt;gx:flyToMode&gt; elements, which specify the time it takes to fly to the defined point from the current point, and the method of flight, respectively.
 
 # Duration and &lt;gx:FlyTo&gt;

 When a duration is included within a &lt;gx:FlyTo&gt; element, it specifies the length of time that the browser takes to fly from the previous point to the specified point.
 */
open class KMLTourFlyTo: KMLTourPrimitive, KMLTourPrimitiveDuration {
    
    @objc public enum FlyToMode: Int, CustomStringConvertible {
        
        /** FlyTos each begin and end at zero velocity. */
        case bounce
        
        /**
         Smooth FlyTos allow for an unbroken flight from point to point to point (and on). An unbroken series of smooth FlyTos will begin and end at zero velocity, and will not slow at each point. A series of smooth FlyTos is broken by any of the following elements:
         
         - &lt;gx:flyToMode&gt;bounce&lt;/gx:flyToMode&gt;
         - &lt;gx:Wait&gt;
         
         This means that velocity will be zero at the smooth FlyTo immediately preceding either of the above elements. A series of smooth FlyTos is not broken by &lt;gx:AnimatedUpdate&gt; elements.
         */
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
        
        public var description: String {
            switch self {
            case .bounce:
                return "bounce"
            case .smooth:
                return "smooth"
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

#if os(macOS)
extension KMLTourFlyTo {

    override class var elementName: String { "gx:FlyTo" }
    
    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "gx:duration", value: duration, default: 0.0)
        addSimpleChild(to: element, withName: "gx:flyToMode", value: mode.description)
        addChild(to: element, child: view, in: doc)
    }
}
#endif

/**
 Contains an &lt;href&gt; element specifying a sound file to play, in MP3, M4A, or AAC format. It does not contain a duration. The sound file plays in parallel to the rest of the tour, meaning that the next tour primitive takes place immediately after the &lt;gx:SoundCue&gt; tour primitive is reached. If another sound file is cued before the first has finished playing, the files are mixed. The &lt;gx:delayedStart&gt; element specifies to delay the start of the sound for a given number of seconds before playing the file.
 */
open class KMLTourSoundCue: KMLTourPrimitive {
    
    /** specifies a sound file to play, in MP3, M4A, or AAC format */
    @objc open var href: URL?
    /** specifies to delay the start of the sound for a given number of seconds before playing the file */
    @objc open var delayedStart: Double = 0.0
    
}

#if os(macOS)
extension KMLTourSoundCue {
    
    override class var elementName: String { "gx:SoundCue" }

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "href", value: href?.description)
        addSimpleChild(to: element, withName: "gx:delayedStart", value: delayedStart, default: 0.0)
    }
}
#endif
