//
//  AbstractUpdateOptionGroup.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

open class KMLUpdateOption: NSObject {
    
}

open class KMLUpdate: NSObject {
    @objc open var targetHref: URL?
    @objc open var sourceHref: URL?
    @objc open var items: [KMLUpdateOption] = []
}

extension KMLUpdate: Sequence {
    public typealias Element = KMLUpdateOption
    public typealias Iterator = Array<Element>.Iterator
    
    public func makeIterator() -> Iterator {
        return items.makeIterator()
    }
}

open class KMLCreate: KMLUpdateOption {
    @objc open var containers: [KMLContainer] = []
    @objc open var multiTracks: [KMLMultiTrack] = []
    @objc open var multiGeometry: [KMLMultiGeometry] = []
}


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

extension KMLChange: Sequence {
    public typealias Element = KMLObject
    public typealias Iterator = Array<Element>.Iterator
    
    public func makeIterator() -> Iterator {
        return objects.makeIterator()
    }
}

open class KMLDelete: KMLUpdateOption {
    @objc open var features: [KMLFeature] = []
    @objc open var geometry: [KMLGeometry] = []
}
