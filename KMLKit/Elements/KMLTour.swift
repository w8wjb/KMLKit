//
//  Tour.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

/**
 &lt;gx:Tour&gt; can contain a single &lt;gx:Playlist&gt; element, which in turn contains an ordered list of gx:TourPrimitive elements that define a tour in any KML browser. [Learn more about tours](https://developers.google.com/kml/documentation/touring).
 */
open class KMLTour: KMLFeature {

    /**
     Contains any number of gx:TourPrimitive elements. There can be zero or one &lt;gx:Playlist&gt; elements contained within a &lt;gx:Tour&gt; element.
     */
    @objc open var playlist = KMLPlaylist()
    
}

#if os(macOS)
extension KMLTour {
    
    override class var elementName: String { "gx:Tour" }

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addChild(to: element, child: playlist, in: doc)
    }
}
#endif

open class KMLPlaylist: KMLObject {
    @objc open var items: [KMLTourPrimitive] = []
}

#if os(macOS)
extension KMLPlaylist {
    
    override class var elementName: String { "gx:Playlist" }

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        for item in items {
            addChild(to: element, child: item, in: doc)
        }
    }
}
#endif

extension KMLPlaylist: Sequence {
    public typealias Element = KMLTourPrimitive
    public typealias Iterator = Array<Element>.Iterator
    
    public func makeIterator() -> Iterator {
        return items.makeIterator()
    }
    
}
