//
//  StyleSelector.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import CoreGraphics

/**
 This is an abstract element and cannot be used directly in a KML file. It is the base type for the &lt;Style&gt; and &lt;StyleMap&gt; elements. The StyleMap element selects a style based on the current mode of the Placemark. An element derived from StyleSelector is uniquely identified by its **id** and its url.
 */
@objc public protocol KMLStyleSelector {
    
}

/**
 A Style defines an addressable style group that can be referenced by StyleMaps and Features. Styles affect how Geometry is presented in the 3D viewer and how Features appear in the Places panel of the List view. Shared styles are collected in a &lt;Document&gt; and must have an **id** defined for them so that they can be referenced by the individual Features that use them.

 Use an **id** to refer to the style from a &lt;styleUrl&gt;.
 */
open class KMLStyle: KMLObject, KMLStyleSelector {
    @objc open var iconStyle: KMLIconStyle?
    @objc open var labelStyle: KMLLabelStyle?
    @objc open var lineStyle: KMLLineStyle?
    @objc open var polyStyle: KMLPolyStyle?
    @objc open var balloonStyle: KMLBalloonStyle?
    @objc open var listStyle: KMLListStyle?
}

#if os(macOS)
extension KMLStyle {

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addChild(to: element, child: iconStyle, in: doc)
        addChild(to: element, child: labelStyle, in: doc)
        addChild(to: element, child: lineStyle, in: doc)
        addChild(to: element, child: polyStyle, in: doc)
        addChild(to: element, child: balloonStyle, in: doc)
        addChild(to: element, child: listStyle, in: doc)
    }
}
#endif

open class KMLSubStyle: KMLStyle {
    
}

/**
 Values for &lt;colorMode&gt; are **normal** (no effect) and **random**. A value of **random** applies a random linear scale to the base &lt;color&gt; as follows.
 - To achieve a truly random selection of colors, specify a base &lt;color&gt; of white (ffffffff).
 - If you specify a single color component (for example, a value of ff0000ff for red), random color values for that one component (red) will be selected. In this case, the values would range from 00 (black) to ff (full red).
 - If you specify values for two or for all three color components, a random linear scale is applied to each color component, with results ranging from black to the maximum values specified for each component.
 - The opacity of a color comes from the alpha component of &lt;color&gt; and is never randomized.
 */
@objc public enum KMLColorMode: Int, CustomStringConvertible {
    case normal
    case random
        
    init(_ value: String) {
        switch value {
        case "normal":
            self = .normal
        case "random":
            self = .random
        default:
            self = .normal
        }
    }
    
    public var description: String {
        switch self {
        case .normal:
            return "normal"
        case .random:
            return "random"
        }
    }
    

    
}

/** This is an abstract element and cannot be used directly in a KML file. It provides elements for specifying the color and color mode of extended style types. */
open class KMLColorStyle: KMLSubStyle {
    @objc open var color = KMLColor.white
    
    @objc open var colorMode = KMLColorMode.normal
    
    open override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "colorMode", let colorMode = value as? KMLColorMode {
            self.colorMode = colorMode
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
    
}

#if os(macOS)
extension KMLColorStyle {

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "color", value: color.kmlHex, default: "ffffffff")
        addSimpleChild(to: element, withName: "colorMode", value: colorMode.description, default: "normal")
    }
}
#endif

/**
 Specifies how the description balloon for placemarks is drawn. The &lt;bgColor&gt;, if specified, is used as the background color of the balloon. See [&lt;Feature&gt;](https://developers.google.com/kml/documentation/kmlreference#feature) for a diagram illustrating how the default description balloon appears in Google Earth.
 */
open class KMLBalloonStyle: KMLColorStyle {
    
    @objc public enum DisplayMode: Int, CustomStringConvertible {
        case `default`
        case hide
        
        init(_ value: String) {
            switch value {
            case "default":
                self = .default
            case "hide":
                self = .hide
            default:
                self = .default
            }
        }
        
        public var description: String {
            switch self {
            case .`default`:
                return "default"
            case .hide:
                return "hide"
            }
        }
    }
    
    /** Background color of the balloon (optional). Color and opacity (alpha) values are expressed in hexadecimal notation. The range of values for any one color is 0 to 255 (00 to ff). The order of expression is aabbggrr, where aa=alpha (00 to ff); bb=blue (00 to ff); gg=green (00 to ff); rr=red (00 to ff). For alpha, 00 is fully transparent and ff is fully opaque. For example, if you want to apply a blue color with 50 percent opacity to an overlay, you would specify the following: &lt;bgColor&gt;7fff0000&lt;/bgColor&gt;, where alpha=0x7f, blue=0xff, green=0x00, and red=0x00. The default is opaque white (ffffffff). */
    @objc open var bgColor: KMLColor?
    
    /** Foreground color for text. The default is black (ff000000). */
    @objc open var textColor: KMLColor?
    
    /**
     Text displayed in the balloon. If no text is specified, Google Earth draws the default balloon (with the Feature &lt;name&gt; in boldface, the Feature &lt;description&gt;, links for driving directions, a white background, and a tail that is attached to the point coordinates of the Feature, if specified).

     You can add entities to the &lt;text&gt; tag using the following format to refer to a child element of Feature: $[name], $[description], $[address], $[id], $[Snippet]. Google Earth looks in the current Feature for the corresponding string entity and substitutes that information in the balloon. To include To here - From here driving directions in the balloon, use the $[geDirections] tag. To prevent the driving directions links from appearing in a balloon, include the &lt;text&gt; element with some content, or with $[description] to substitute the basic Feature &lt;description&gt;.

     For example, in the following KML excerpt, $[name] and $[description] fields will be replaced by the &lt;name&gt; and &lt;description&gt; fields found in the Feature elements that use this BalloonStyle:
     ```
     <text>This is $[name], whose description is:<br/>$[description]</text>
     ```
     */
    @objc open var text = ""
    
    /** If &lt;displayMode&gt; is default, Google Earth uses the information supplied in &lt;text&gt; to create a balloon . If &lt;displayMode&gt; is hide, Google Earth does not display the balloon. In Google Earth, clicking the List View icon for a Placemark whose balloon's &lt;displayMode&gt; is hide causes Google Earth to fly to the Placemark. */
    @objc open var displayMode = DisplayMode.default
    
    open override func setValue(_ value: Any?, forKey key: String) {
        if key == "displayMode", let displayMode = value as? DisplayMode {
            self.displayMode = displayMode
        } else {
            super.setValue(value, forKey: key)
        }
    }
}

#if os(macOS)
extension KMLBalloonStyle {

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "bgColor", value: bgColor?.kmlHex, default: "ffffffff")
        addSimpleChild(to: element, withName: "textColor", value: textColor?.kmlHex, default: "ffffffff")
        addSimpleChild(to: element, withName: "text", value: text, default: "")
        addSimpleChild(to: element, withName: "displayMode", value: displayMode.description, default: "default")
    }
}
#endif

/**
 Specifies how the &lt;name&gt; of a Feature is drawn in the 3D viewer. A custom color, color mode, and scale for the label (name) can be specified.
 */
open class KMLLabelStyle: KMLColorStyle {
    /** Resizes the label. */
    @objc open var scale: Double = 1.0
}

#if os(macOS)
extension KMLLabelStyle {

    override func toElement(in doc: XMLDocument) -> XMLElement {
        let element = super.toElement(in: doc)
        addSimpleChild(to: element, withName: "scale", value: scale, default: 1.0)
        return element
    }
}
#endif

/**
 Specifies the drawing style (color, color mode, and line width) for all line geometry. Line geometry includes the outlines of outlined polygons and the extruded "tether" of Placemark icons (if extrusion is enabled).
 */
open class KMLLineStyle: KMLColorStyle {
    /** Width of the line, in pixels. */
    @objc open var width: Double = 1.0
}

#if os(macOS)
extension KMLLineStyle {

    override func toElement(in doc: XMLDocument) -> XMLElement {
        let element = super.toElement(in: doc)
        addSimpleChild(to: element, withName: "width", value: width, default: 1.0)
        return element
    }
}
#endif

open class KMLItemIcon: KMLObject {
    
    @objc(KMLItemIconState)
    public enum IconState: Int, CustomStringConvertible {
        case `open`
        case closed
        case error
        case fetching0
        case fetching1
        case fetching2
        
        init(_ value: String) {
            switch value {
            case "open":
                self = .open
            case "closed":
                self = .closed
            case "error":
                self = .error
            case "fetching0":
                self = .fetching0
            case "fetching1":
                self = .fetching1
            case "fetching2":
                self = .fetching2
            default:
                self = .open
            }
        }
        
        public var description: String {
            switch self {
            case .open:
                return "open"
            case .closed:
                return "closed"
            case .error:
                return "error"
            case .fetching0:
                return "fetching0"
            case .fetching1:
                return "fetching1"
            case .fetching2:
                return "fetching2"
            }
        }
    }
    
    /** Specifies the current state of the NetworkLink or Folder */
    @objc open var state: IconState = .open
    
    /** Specifies the URI of the image used in the List View for the Feature. */
    @objc open var href: URL?
    
    open override func setValue(_ value: Any?, forKey key: String) {
        if key == "state", let state = value as? IconState {
            self.state = state
        } else {
            super.setValue(value, forKey: key)
        }
    }
}

#if os(macOS)
extension KMLItemIcon {

    override func toElement(in doc: XMLDocument) -> XMLElement {
        let element = super.toElement(in: doc)
        addSimpleChild(to: element, withName: "state", value: state.description)
        addSimpleChild(to: element, withName: "href", value: href?.description)
        return element
    }
}
#endif

/**
 Specifies how a Feature is displayed in the list view. The list view is a hierarchy of containers and children; in Google Earth, this is the Places panel.
 */
open class KMLListStyle: KMLSubStyle {
    
    @objc(KMLListItemType) public enum ListItemType: Int, CustomStringConvertible {
        /** When specified for a Container, only one of the Container's items is visible at a time */
        case radioFolder
        /** The Feature's visibility is tied to its item's checkbox. */
        case check
        /** Use a normal checkbox for visibility but do not display the Container or Network Link's children in the list view. A checkbox allows the user to toggle visibility of the child objects in the viewer. */
        case checkHideChildren
        /** When specified for a Container or Network Link, prevents all items from being made visible at once—that is, the user can turn everything in the Container or Network Link off but cannot turn everything on at the same time. This setting is useful for Containers or Network Links containing large amounts of data. */
        case checkOffOnly
        
        init(_ value: String) {
            switch value {
            case "radioFolder":
                self = .radioFolder
            case "check":
                self = .check
            case "checkHideChildren":
                self = .checkHideChildren
            case "checkOffOnly":
                self = .checkOffOnly
            default:
                self = .check
            }
        }
        
        public var description: String {
            switch self {
            case .radioFolder:
                return "radioFolder"
            case .check:
                return "check"
            case .checkHideChildren:
                return "checkHideChildren"
            case .checkOffOnly:
                return "checkOffOnly"
            }
        }
    }
    
    /** Specifies how a Feature is displayed in the list view */
    @objc open var listItemType = ListItemType.check
    
    /** Background color for the Snippet */
    @objc open var bgColor = KMLColor.white
    
    /** Icon used in the List view that reflects the state of a Folder or Link fetch. Icons associated with the **open** and **closed** modes are used for Folders and Network Links. Icons associated with the **error** and **fetching0**, **fetching1**, and **fetching2** modes are used for Network Links. */
    @objc open var itemIcon: [KMLItemIcon] = []
    @objc open var maxSnippetLines = 2
    
    
    open override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "listItemType", let listItemType = value as? ListItemType {
            self.listItemType = listItemType
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
}

#if os(macOS)
extension KMLListStyle {

    override func toElement(in doc: XMLDocument) -> XMLElement {
        let element = super.toElement(in: doc)
        addSimpleChild(to: element, withName: "listItemType", value: listItemType.description)
        addSimpleChild(to: element, withName: "bgColor", value: bgColor.kmlHex, default: "ffffffff")
        for child in itemIcon {
            addChild(to: element, child: child, in: doc)
        }
        addSimpleChild(to: element, withName: "maxSnippetLines", value: maxSnippetLines, default: 2)
        return element
    }
}
#endif

/**
 Specifies the drawing style for all polygons, including polygon extrusions (which look like the walls of buildings) and line extrusions (which look like solid fences).
 */
open class KMLPolyStyle: KMLColorStyle {
    /** Specifies whether to fill the polygon. */
    @objc open var fill = true
    /** Specifies whether to outline the polygon. Polygon outlines use the current LineStyle. */
    @objc open var outline = true
}

#if os(macOS)
extension KMLPolyStyle {

    override func toElement(in doc: XMLDocument) -> XMLElement {
        let element = super.toElement(in: doc)
        addSimpleChild(to: element, withName: "fill", value: fill, numeric: true, default: true)
        addSimpleChild(to: element, withName: "outline", value: outline, numeric: true, default: true)
        return element
    }
}
#endif

/**
 Specifies how icons for point Placemarks are drawn, both in the Places panel and in the 3D viewer of Google Earth. The &lt;Icon&gt; element specifies the icon image. The &lt;scale&gt; element specifies the x, y scaling of the icon. The color specified in the &lt;color&gt; element of &lt;IconStyle&gt; is blended with the color of the &lt;Icon&gt;.
 */
open class KMLIconStyle: KMLColorStyle {
    /** Resizes the icon. */
    @objc open var scale: Double = 1.0
    /** Direction (that is, North, South, East, West), in degrees. Default=0 (North). Values range from 0 to 360 degrees. */
    @objc open var heading: Double = 0.0
    /** A custom Icon. In &lt;IconStyle&gt;, the only child element of &lt;Icon&gt; is &lt;href&gt;: */
    @objc open var icon: KMLIcon?
    
    /** Specifies the position within the Icon that is "anchored" to the &lt;Point&gt; specified in the Placemark. The x and y values can be specified in three different ways: as pixels ("pixels"), as fractions of the icon ("fraction"), or as inset pixels ("insetPixels"), which is an offset in pixels from the upper right corner of the icon. The x and y positions can be specified in different ways—for example, x can be in pixels and y can be a fraction. The origin of the coordinate system is in the lower left corner of the icon. */
    open var hotSpot = CGPoint()
    
    open override func setValue(_ value: Any?, forKey key: String) {
        if key == "hotSpot", let hotSpot = value as? CGPoint {
            self.hotSpot = hotSpot
        } else {
            super.setValue(value, forKey: key)
        }
    }
}

#if os(macOS)
extension KMLIconStyle {

    override func toElement(in doc: XMLDocument) -> XMLElement {
        let element = super.toElement(in: doc)
        addSimpleChild(to: element, withName: "scale", value: scale, default: 1.0)
        addSimpleChild(to: element, withName: "heading", value: heading, default: 0.0)
        addChild(to: element, child: icon, in: doc)
        
        if hotSpot != CGPoint() {
            addSimpleChild(to: element, withName: "hotSpot", value: hotSpot)
        }
        
        return element
    }
}
#endif

open class KMLStyleRef: NSObject, KMLStyleSelector {
    @objc open var styleUrl: URL
    
    public init(styleUrl: URL) {
        self.styleUrl = styleUrl
        super.init()
    }
    
}

#if os(macOS)
extension KMLStyleRef: KMLWriterNode {
    static let elementName = "styleUrl"
    
    func toElement(in doc: XMLDocument) -> XMLElement {
        let element = XMLElement(name: type(of: self).elementName)
        element.setStringValue(styleUrl.description, resolvingEntities: false)
        return element
    }
}
#endif

/**
 A &lt;StyleMap&gt; maps between two different Styles.
 
 Typically a &lt;StyleMap&gt; element is used to provide separate normal and highlighted styles for a placemark, so that the highlighted version appears when the user mouses over the icon in Google Earth.
 */
open class KMLStyleMap: KMLObject, KMLStyleSelector {
    
    /**
     Defines a key/value pair that maps a mode (normal or highlight) to the predefined &lt;styleUrl&gt;.
     
     &lt;Pair&gt; contains two elements (both are required):
     - **&lt;key&gt;**, which identifies the key
     - **&lt;styleUrl&gt;** or **&lt;Style&gt;**, which references the style. In &lt;styleUrl&gt;, for referenced style elements that are local to the KML document, a simple # referencing is used. For styles that are contained in external files, use a full URL along with # referencing. For example:
     */
    @objc open var pairs: [String:KMLStyleSelector] = [:]
}

#if os(macOS)
extension KMLStyleMap {

    override func toElement(in doc: XMLDocument) -> XMLElement {
        let element = super.toElement(in: doc)
        
        for (key, value) in pairs {
            guard let styleWriterNode = value as? KMLWriterNode else { continue }
            
            let keyElement = XMLElement(name: "key", stringValue: key)
            let valueElement = styleWriterNode.toElement(in: doc)
            
            let pairElement = XMLNode.element(withName: "Pair", children: [keyElement, valueElement], attributes: nil) as! XMLNode
            element.addChild(pairElement)
        }
        
        return element
    }
}
#endif

extension KMLStyleMap: Sequence {

    public typealias Element = (key: String, value: KMLStyleSelector)
    public typealias Iterator = Dictionary<String, KMLStyleSelector>.Iterator
    
    public func makeIterator() -> Iterator {
        return pairs.makeIterator()
    }

}

// Pseudo-dictionary interface
extension KMLStyleMap {
    
    subscript(key: String) -> KMLStyleSelector? {
        return pairs[key]
    }
    
    public var keys: Dictionary<String, KMLStyleSelector>.Keys {
        return pairs.keys
    }
    
    public var values: Dictionary<String, KMLStyleSelector>.Values {
        return pairs.values
    }
}


