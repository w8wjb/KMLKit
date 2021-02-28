//
//  AbstractUpdateOptionGroup.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class KMLUpdateOption: NSObject {
    
}

public class KMLUpdate: NSObject {
    @objc public var targetHref: URL?
    @objc public var sourceHref: URL?
    @objc public var items: [KMLUpdateOption] = []
}

extension KMLUpdate: Sequence {
    public typealias Element = KMLUpdateOption
    public typealias Iterator = Array<Element>.Iterator
    
    public func makeIterator() -> Iterator {
        return items.makeIterator()
    }
}

public class KMLCreate: KMLUpdateOption {
    @objc public var containers: [KMLContainer] = []
    @objc public var multiTracks: [KMLMultiTrack] = []
    @objc public var multiGeometry: [KMLMultiGeometry] = []
}


public class KMLChange: KMLUpdateOption {
    @objc public var objects: [KMLObject] = []
    
    public override func setValue(_ value: Any?, forKey key: String) {
        if let obj = value as? KMLObject {
            objects.append(obj)
        } else {
            super.setValue(value, forKey: key)
        }
    }
}

extension KMLChange: Sequence {
    public typealias Element = KMLObject
    public typealias Iterator = Array<Element>.Iterator
    
    public func makeIterator() -> Iterator {
        return objects.makeIterator()
    }
}

public class KMLDelete: KMLUpdateOption {
    @objc public var features: [KMLFeature] = []
    @objc public var geometry: [KMLGeometry] = []
}
