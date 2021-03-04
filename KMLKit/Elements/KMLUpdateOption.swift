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
extension KMLUpdateOption: KMLWriterNode {
    
    class var elementName: String { fatalError("override in subclass") }

    func toElement() -> XMLElement {
        let element = XMLElement(name: type(of: self).elementName)
        return element
    }
}
#endif

open class KMLUpdate: NSObject {
    @objc open var targetHref: URL?
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

    func toElement() -> XMLElement {
        let element = XMLElement(name: type(of: self).elementName)
        addSimpleChild(to: element, withName: "targetHref", value: targetHref)
        
        for child in items {
            addChild(to: element, child: child)
        }
        
        return element
    }
}
#endif

open class KMLCreate: KMLUpdateOption {
    @objc open var containers: [KMLContainer] = []
    @objc open var multiTracks: [KMLMultiTrack] = []
    @objc open var multiGeometry: [KMLMultiGeometry] = []
}

#if os(macOS)
extension KMLCreate {
    class override var elementName: String { "#KMLUpdateOption#" }

    override func toElement() -> XMLElement {
        let element = super.toElement()
        
        for child in containers {
            addChild(to: element, child: child)
        }

        for child in multiTracks {
            addChild(to: element, child: child)
        }

        for child in multiGeometry {
            addChild(to: element, child: child)
        }

        return element
    }
}
#endif

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

    override func toElement() -> XMLElement {
        let element = super.toElement()
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

open class KMLDelete: KMLUpdateOption {
    @objc open var features: [KMLFeature] = []
    @objc open var geometry: [KMLGeometry] = []
}

#if os(macOS)
extension KMLDelete {
    class override var elementName: String { "Delete" }

    override func toElement() -> XMLElement {
        let element = super.toElement()
        
        for child in features {
            addChild(to: element, child: child)
        }

        for child in geometry {
            addChild(to: element, child: child)
        }

        return element
    }
}
#endif
