//
//  Tour.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class KMLTour: KMLFeature {

    @objc public var playlist = KMLPlaylist()
    
}

public class KMLPlaylist: KMLObject {

    @objc public var items: [KMLTourPrimitive] = []

    
}

extension KMLPlaylist: Sequence {
    public typealias Element = KMLTourPrimitive
    public typealias Iterator = Array<Element>.Iterator
    
    public func makeIterator() -> Iterator {
        return items.makeIterator()
    }
    
}
