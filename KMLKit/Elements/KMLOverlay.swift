//
//  Overlay.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import CoreLocation
import MapKit

/**
 This is an abstract element and cannot be used directly in a KML file. &lt;Overlay&gt; is the base type for image overlays drawn on the planet surface or on the screen. &lt;Icon&gt; specifies the image to use and can be configured to reload images based on a timer or by camera changes. This element also includes specifications for stacking order of multiple overlays and for adding color and transparency values to the base image.
 */
open class KMLOverlay: KMLFeature {

    @objc open var color: KMLColor?
    
    /** This element defines the stacking order for the images in overlapping overlays. Overlays with higher &lt;drawOrder&gt; values are drawn on top of overlays with lower &lt;drawOrder&gt; values. */
    @objc open var drawOrder = 0
    
    /** Defines the image associated with the Overlay. The &lt;href&gt; element defines the location of the image to be used as the Overlay. This location can be either on a local file system or on a web server. If this element is omitted or contains no &lt;href&gt;, a rectangle is drawn using the color and size defined by the ground or screen overlay. */
    @objc open var icon: KMLIcon?
    
}

#if os(macOS)
extension KMLOverlay {

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "color", value: color?.hexRGBaColor)
        addSimpleChild(to: element, withName: "drawOrder", value: drawOrder, default: 0)
        addChild(to: element, child: icon, in: doc)
    }

}
#endif

/**
 This element draws an image overlay draped onto the terrain. The &lt;href&gt; child of &lt;Icon&gt; specifies the image to be used as the overlay. This file can be either on a local file system or on a web server. If this element is omitted or contains no &lt;href&gt;, a rectangle is drawn using the color and LatLonBox bounds defined by the ground overlay.
 */
open class KMLGroundOverlay: KMLOverlay {
    
    /** Specifies the distance above the earth's surface, in meters, and is interpreted according to the altitude mode. */
    @objc open var altitude: CLLocationDistance = 0.0
    /** Specifies how the &lt;altitude&gt;is interpreted */
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

#if os(macOS)
extension KMLGroundOverlay {

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "altitude", value: altitude, default: 0)
        addSimpleChild(to: element, withName: "altitudeMode", value: altitudeMode.description, default: "clampToGround")
        addChild(to: element, child: extent, in: doc)
    }
}
#endif

/**
 The &lt;PhotoOverlay&gt; element allows you to geographically locate a photograph on the Earth and to specify viewing parameters for this PhotoOverlay. The PhotoOverlay can be a simple 2D rectangle, a partial or full cylinder, or a sphere (for spherical panoramas). The overlay is placed at the specified location and oriented toward the viewpoint.

 Because &lt;PhotoOverlay&gt; is derived from &lt;Feature&gt;, it can contain one of the two elements derived from &lt;AbstractView&gt;—either &lt;Camera&gt; or &lt;LookAt&gt;. The Camera (or LookAt) specifies a viewpoint and a viewing direction (also referred to as a view vector). The PhotoOverlay is positioned in relation to the viewpoint. Specifically, the plane of a 2D rectangular image is orthogonal (at right angles to) the view vector. The normal of this plane—that is, its front, which is the part with the photo—is oriented toward the viewpoint.

 The URL for the PhotoOverlay image is specified in the &lt;Icon&gt; tag, which is inherited from &lt;Overlay&gt;. The &lt;Icon&gt; tag must contain an &lt;href&gt; element that specifies the image file to use for the PhotoOverlay. In the case of a very large image, the &lt;href&gt; is a special URL that indexes into a pyramid of images of varying resolutions (see [ImagePyramid](https://developers.google.com/kml/documentation/kmlreference#imagepyramid)).

 For more information, see the "Topics in KML" page on [PhotoOverlay](https://developers.google.com/kml/documentation/photos).
 */
open class KMLPhotoOverlay: KMLOverlay {
    
    /**
     Defines how much of the current scene is visible. Specifying the field of view is analogous to specifying the lens opening in a physical camera. A small field of view, like a telephoto lens, focuses on a small part of the scene. A large field of view, like a wide-angle lens, focuses on a large part of the scene.
     */
    open class ViewVolume: NSObject {
        /** Angle, in degrees, between the camera's viewing direction and the left side of the view volume. */
        @objc open var leftFov: Double = 0.0
        /** Angle, in degrees, between the camera's viewing direction and the right side of the view volume. */
        @objc open var rightFov: Double = 0.0
        /** Angle, in degrees, between the camera's viewing direction and the bottom side of the view volume. */
        @objc open var bottomFov: Double = 0.0
        /** Angle, in degrees, between the camera's viewing direction and the top side of the view volume. */
        @objc open var topFov: Double = 0.0
        /** Measurement in meters along the viewing direction from the camera viewpoint to the PhotoOverlay shape. */
        @objc open var near: Double = 0.0
    }
    
    @objc public enum GridOrigin: Int, CustomStringConvertible {
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
        
        public var description: String {
            switch self {
            case .lowerLeft:
                return "lowerLeft"
            case .upperLeft:
                return "upperLeft"
            }
        }
    }
    
    
    /**
     For very large images, you'll need to construct an image pyramid, which is a hierarchical set of images, each of which is an increasingly lower resolution version of the original image. Each image in the pyramid is subdivided into tiles, so that only the portions in view need to be loaded. Google Earth calculates the current viewpoint and loads the tiles that are appropriate to the user's distance from the image. As the viewpoint moves closer to the PhotoOverlay, Google Earth loads higher resolution tiles. Since all the pixels in the original image can't be viewed on the screen at once, this preprocessing allows Google Earth to achieve maximum performance because it loads only the portions of the image that are in view, and only the pixel details that can be discerned by the user at the current viewpoint.
     
     When you specify an image pyramid, you also modify the &lt;href&gt; in the &lt;Icon&gt; element to include specifications for which tiles to load.
     */
    open class ImagePyramid: NSObject {
        
        /** Size of the tiles, in pixels. Tiles must be square, and &lt;tileSize&gt; must be a power of 2. A tile size of 256 (the default) or 512 is recommended. The original image is divided into tiles of this size, at varying resolutions. */
        @objc open var tileSize = 256
        /** Width in pixels of the original image. */
        @objc open var maxWidth = 0
        /** Height in pixels of the original image. */
        @objc open var maxHeight = 0
        /** Specifies where to begin numbering the tiles in each layer of the pyramid. A value of **lowerLeft** specifies that row 1, column 1 of each layer is in the bottom left corner of the grid */
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
        /** for an ordinary photo */
        case rectangle
        /** for panoramas, which can be either partial or full cylinders */
        case cylinder
        /** for spherical panoramas */
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
        
        public var description: String {
            switch self {
            case .rectangle:
                return "rectangle"
            case .cylinder:
                return "cylinder"
            case .sphere:
                return "sphere"
            }
        }
    }
    

    /** Adjusts how the photo is placed inside the field of view. This element is useful if your photo has been rotated and deviates slightly from a desired horizontal view. */
    @objc open var rotation: Double = 0.0
    /** Defines how much of the current scene is visible. */
    @objc open var viewVolume: ViewVolume?
    /** For very large images, you'll need to construct an image pyramid, which is a hierarchical set of images, each of which is an increasingly lower resolution version of the original image */
    @objc open var imagePyramid: ImagePyramid?
    /** The &lt;Point&gt; element acts as a &lt;Point&gt; inside a &lt;Placemark&gt; element. It draws an icon to mark the position of the PhotoOverlay. The icon drawn is specified by the &lt;styleUrl&gt; and &lt;StyleSelector&gt; fields, just as it is for &lt;Placemark&gt;. */
    @objc open var point: KMLPoint?
    /** The PhotoOverlay is projected onto the &lt;shape&gt;. */
    @objc open var shape = Shape.rectangle
    
    open override func setValue(_ value: Any?, forKey key: String) {        
        if key == "shape", let shape = value as? Shape {
            self.shape = shape
        } else {
            super.setValue(value, forKey: key)
        }
    }
}

#if os(macOS)
extension KMLPhotoOverlay {

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "rotation", value: rotation, default: 0)
        addChild(to: element, child: viewVolume, in: doc)
        addChild(to: element, child: imagePyramid, in: doc)
        addChild(to: element, child: point, in: doc)
        addSimpleChild(to: element, withName: "gridOrigin", value: shape.description, default: "rectangle")
    }
}

extension KMLPhotoOverlay.ViewVolume: KMLWriterNode {
    static let elementName = "ViewVolume"
    
    func toElement(in doc: XMLDocument) -> XMLElement {
        let element = XMLElement(name: type(of: self).elementName)
        addSimpleChild(to: element, withName: "leftFov", value: leftFov, default: 0)
        addSimpleChild(to: element, withName: "rightFov", value: rightFov, default: 0)
        addSimpleChild(to: element, withName: "bottomFov", value: bottomFov, default: 0)
        addSimpleChild(to: element, withName: "topFov", value: topFov, default: 0)
        addSimpleChild(to: element, withName: "near", value: near, default: 0)
        return element
    }
}

extension KMLPhotoOverlay.ImagePyramid: KMLWriterNode {
    static let elementName = "ImagePyramid"
    
    func toElement(in doc: XMLDocument) -> XMLElement {
        let element = XMLElement(name: type(of: self).elementName)
        addSimpleChild(to: element, withName: "tileSize", value: tileSize, default: 256)
        addSimpleChild(to: element, withName: "maxWidth", value: maxWidth, default: 0)
        addSimpleChild(to: element, withName: "maxHeight", value: maxHeight, default: 0)
        addSimpleChild(to: element, withName: "gridOrigin", value: gridOrigin.description, default: "lowerLeft")
        return element
    }
}

#endif

/**
 This element draws an image overlay fixed to the screen. Sample uses for ScreenOverlays are compasses, logos, and heads-up displays. ScreenOverlay sizing is determined by the &lt;size&gt; element. Positioning of the overlay is handled by mapping a point in the image specified by &lt;overlayXY&gt; to a point on the screen specified by &lt;screenXY&gt;. Then the image is rotated by &lt;rotation&gt; degrees about a point relative to the screen specified by &lt;rotationXY&gt;.

 The &lt;href&gt; child of &lt;Icon&gt; specifies the image to be used as the overlay. This file can be either on a local file system or on a web server. If this element is omitted or contains no &lt;href&gt;, a rectangle is drawn using the color and size defined by the screen overlay.
 */
open class KMLScreenOverlay: KMLOverlay {
    
    /**
     Specifies a point on (or outside of) the overlay image that is mapped to the screen coordinate (&lt;screenXY&gt;). It requires x and y values, and the units for those values.
     
     The x and y values can be specified in three different ways: as pixels ("pixels"), as fractions of the image ("fraction"), or as inset pixels ("insetPixels"), which is an offset in pixels from the upper right corner of the image. The x and y positions can be specified in different ways—for example, x can be in pixels and y can be a fraction. The origin of the coordinate system is in the lower left corner of the image.
     */
    open var overlayXY: CGPoint?
    
    /**
     Specifies a point relative to the screen origin that the overlay image is mapped to. The x and y values can be specified in three different ways: as pixels ("pixels"), as fractions of the screen ("fraction"), or as inset pixels ("insetPixels"), which is an offset in pixels from the upper right corner of the screen. The x and y positions can be specified in different ways—for example, x can be in pixels and y can be a fraction. The origin of the coordinate system is in the lower left corner of the screen.
     */
    open var screenXY: CGPoint?
    
    /** Point relative to the screen about which the screen overlay is rotated. */
    open var rotationXY: CGPoint?
    
    /**
     Specifies the size of the image for the screen overlay, as follows:
     - A value of −1 indicates to use the native dimension
     - A value of 0 indicates to maintain the aspect ratio
     - A value of *n* sets the value of the dimension
     */
    open var size: CGSize?
    /**
     Indicates the angle of rotation of the parent object. A value of 0 means no rotation.
     
     The value is an angle in degrees counterclockwise starting from north. Use ±180 to indicate the rotation of the parent object from 0. The center of the <rotation>, if not (.5,.5), is specified in <rotationXY>.
     */
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

#if os(macOS)
extension KMLScreenOverlay {

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "overlayXY", value: overlayXY)
        addSimpleChild(to: element, withName: "screenXY", value: screenXY)
        addSimpleChild(to: element, withName: "rotationXY", value: rotationXY)
        addSimpleChild(to: element, withName: "size", value: size)
        addSimpleChild(to: element, withName: "rotation", value: rotation, default: 0)
    }
}
#endif
