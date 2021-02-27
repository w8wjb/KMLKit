//
//  AbstractUpdateOptionGroup.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class UpdateOption {
    
}

public class Update {
    public var targetHref: URL?
    public var sourceHref: URL?
    public var items: [UpdateOption] = []
}

extension Update: Sequence {
    public typealias Element = UpdateOption
    public typealias Iterator = Array<Element>.Iterator
    
    public func makeIterator() -> Iterator {
        return items.makeIterator()
    }
}

public class Create: UpdateOption {
    public var containers: [Container] = []
    public var multiTracks: [MultiTrack] = []
    public var multiGeometry: [MultiGeometry] = []
}


public class Change: UpdateOption {
    public var objects: [KmlObject] = []
    
}

extension Change: Sequence {
    public typealias Element = KmlObject
    public typealias Iterator = Array<Element>.Iterator
    
    public func makeIterator() -> Iterator {
        return objects.makeIterator()
    }
}

public class Delete: UpdateOption {
    public var features: [Feature] = []
    public var geometry: [Geometry] = []
}
