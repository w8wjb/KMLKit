//
//  AbstractUpdateOptionGroup.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class KMLUpdateOption: NSObject {
    
}

public class Update: NSObject {
    public var targetHref: URL?
    public var sourceHref: URL?
    public var items: [KMLUpdateOption] = []
}

extension Update: Sequence {
    public typealias Element = KMLUpdateOption
    public typealias Iterator = Array<Element>.Iterator
    
    public func makeIterator() -> Iterator {
        return items.makeIterator()
    }
}

public class Create: KMLUpdateOption {
    public var containers: [KMLContainer] = []
    public var multiTracks: [KMLMultiTrack] = []
    public var multiGeometry: [KMLMultiGeometry] = []
}


public class Change: KMLUpdateOption {
    public var objects: [KMLObject] = []
    
}

extension Change: Sequence {
    public typealias Element = KMLObject
    public typealias Iterator = Array<Element>.Iterator
    
    public func makeIterator() -> Iterator {
        return objects.makeIterator()
    }
}

public class Delete: KMLUpdateOption {
    public var features: [KMLFeature] = []
    public var geometry: [KMLGeometry] = []
}
