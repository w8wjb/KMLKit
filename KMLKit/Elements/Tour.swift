//
//  Tour.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class Tour: Feature {

    public var playlist = Playlist()
    
}

public class Playlist: KmlObject {

    public var items: [TourPrimitive] = []

    
}

extension Playlist: Sequence {
    public typealias Element = TourPrimitive
    public typealias Iterator = Array<Element>.Iterator
    
    public func makeIterator() -> Iterator {
        return items.makeIterator()
    }
    
}
