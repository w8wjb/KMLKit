//
//  AbstractUpdateOptionGroup.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

open class KMLUpdateOption: NSObject {
    
}

#if os(macOS)
@objc extension KMLUpdateOption: KMLWriterNode {
    
    class var elementName: String { fatalError("override in subclass") }
    
    internal func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
    }
    
    internal func toElement(in doc: XMLDocument) -> XMLElement {
        let element = XMLElement(name: type(of: self).elementName)
        addChildNodes(to: element, in: doc)
        return element
    }
}
#endif

/**
 Specifies an addition, change, or deletion to KML data that has already been loaded using the specified URL.
 
 The &lt;targetHref&gt; specifies the .kml or .kmz file whose data (within Google Earth) is to be modified. &lt;Update&gt; is always contained in a NetworkLinkControl. Furthermore, the file containing the NetworkLinkControl must have been loaded by a NetworkLink. See the "Topics in KML" page on Updates for a detailed example of how Update works.
 */
open class KMLUpdate: NSObject {
    /**
     A URL that specifies the .kml or .kmz file whose data (within Google Earth) is to be modified by an &lt;Update&gt; element.
     
     This KML file must already have been loaded via a &lt;NetworkLink&gt;. In that file, the element to be modified must already have an explicit id attribute defined for it.
     */
    @objc open var targetHref: URL?
    
    /** Can contain any number of &lt;Change&gt;, &lt;Create&gt;, and &lt;Delete&gt; elements, which will be processed in order. */
    @objc open var items: [KMLUpdateOption] = []
}

extension KMLUpdate: Sequence {
    public typealias Element = KMLUpdateOption
    public typealias Iterator = Array<Element>.Iterator
    
    public func makeIterator() -> Iterator {
        return items.makeIterator()
    }
}

#if os(macOS)
extension KMLUpdate: KMLWriterNode {
    class var elementName: String { "Update" }

    func toElement(in doc: XMLDocument) -> XMLElement {
        let element = XMLElement(name: type(of: self).elementName)
        addSimpleChild(to: element, withName: "targetHref", value: targetHref)
        
        for child in items {
            addChild(to: element, child: child, in: doc)
        }
        
        return element
    }
}
#endif

/**
 Adds new elements to a Folder or Document that has already been loaded via a &lt;NetworkLink&gt;.
 
 The &lt;targetHref&gt; element in &lt;Update&gt; specifies the URL of the .kml or .kmz file that contained the original Folder or Document. Within that file, the Folder or Document that is to contain the new data must already have an explicit **id** defined for it. This **id** is referenced as the **targetId** attribute of the Folder or Document within &lt;Create&gt; that contains the element to be added.
 
 Once an object has been created and loaded into Google Earth, it takes on the URL of the original parent Document of Folder. To perform subsequent updates to objects added with this Update/Create mechanism, set &lt;targetHref&gt; to the URL of the original Document or Folder (not the URL of the file that loaded the intervening updates).
 */
open class KMLCreate: KMLUpdateOption {
    @objc open var containers: [KMLContainer] = []
    @objc open var multiTracks: [KMLMultiTrack] = []
    @objc open var multiGeometry: [KMLMultiGeometry] = []
}

#if os(macOS)
extension KMLCreate {
    class override var elementName: String { "#KMLUpdateOption#" }

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)

        for child in containers {
            addChild(to: element, child: child, in: doc)
        }

        for child in multiTracks {
            addChild(to: element, child: child, in: doc)
        }

        for child in multiGeometry {
            addChild(to: element, child: child, in: doc)
        }

    }
}
#endif

/**
 Modifies the values in an element that has already been loaded with a &lt;NetworkLink&gt;. Within the Change element, the child to be modified must include a **targetId** attribute that references the original element's **id**.
 
 This update can be considered a "sparse update": in the modified element, only the values listed in &lt;Change&gt; are replaced; all other values remained untouched. When &lt;Change&gt; is applied to a set of coordinates, the new coordinates replace the current coordinates.
 
 Children of this element are the element(s) to be modified, which are identified by the **targetId** attribute.
 */
open class KMLChange: KMLUpdateOption {
    @objc open var objects: [KMLObject] = []
    
    open override func setValue(_ value: Any?, forKey key: String) {
        if let obj = value as? KMLObject {
            objects.append(obj)
        } else {
            super.setValue(value, forKey: key)
        }
    }
}

#if os(macOS)
extension KMLChange {
    class override var elementName: String { "Change" }

    override func toElement(in doc: XMLDocument) -> XMLElement {
        let element = super.toElement(in: doc)
        return element
    }
}
#endif

extension KMLChange: Sequence {
    public typealias Element = KMLObject
    public typealias Iterator = Array<Element>.Iterator
    
    public func makeIterator() -> Iterator {
        return objects.makeIterator()
    }
}

/**
 Deletes features from a complex element that has already been loaded via a &lt;NetworkLink&gt;. The &lt;targetHref&gt; element in &lt;Update&gt; specifies the .kml or .kmz file containing the data to be deleted. Within that file, the element to be deleted must already have an explicit **id** defined for it. The &lt;Delete&gt; element references this **id** in the **targetId** attribute.
 
 Child elements for &lt;Delete&gt;, which are the only elements that can be deleted, are Document, Folder, GroundOverlay, Placemark, and ScreenOverlay.
 */
open class KMLDelete: KMLUpdateOption {
    @objc open var features: [KMLFeature] = []
    @objc open var geometry: [KMLGeometry] = []
}

#if os(macOS)
extension KMLDelete {
    class override var elementName: String { "Delete" }

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)

        for child in features {
            addChild(to: element, child: child, in: doc)
        }

        for child in geometry {
            addChild(to: element, child: child, in: doc)
        }
    }
}
#endif
