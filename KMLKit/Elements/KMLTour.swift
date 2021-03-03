//
//  Tour.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

open class KMLTour: KMLFeature {

    @objc open var playlist = KMLPlaylist()
    
}

open class KMLPlaylist: KMLObject {

    @objc open var items: [KMLTourPrimitive] = []

    
}

extension KMLPlaylist: Sequence {
    public typealias Element = KMLTourPrimitive
    public typealias Iterator = Array<Element>.Iterator
    
    public func makeIterator() -> Iterator {
        return items.makeIterator()
    }
    
}
