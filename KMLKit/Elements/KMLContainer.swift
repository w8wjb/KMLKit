//
//  Container.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public protocol KMLFeatureCollection {
    
    func add(feature: KMLFeature)
    func findFirstFeature<T>(ofType type: T.Type) -> T?
    func findFeatures<T:KMLFeature>(ofType type: T.Type) -> [T]
}


/**
 This is an abstract element and cannot be used directly in a KML file. A Container element holds one or more Features and allows the creation of nested hierarchies.
 */
open class KMLContainer: KMLFeature, KMLFeatureCollection {

    var features: [KMLFeature] = []

    open func add(feature: KMLFeature) {
        features.append(feature)
    }

    open func findFeatures<T:KMLFeature>(ofType type: T.Type) -> [T] {
        
        var found: [T] = []
        
        for feature in self {
            
            if let match = feature as? T {
                found.append(match)
            }
            
            if let collection = feature as? KMLFeatureCollection {
                found.append(contentsOf: collection.findFeatures(ofType: type))
            }
            
        }

        return found
    }

    
    open func findFirstFeature<T>(ofType type: T.Type) -> T? {
        
        for feature in self {
            if let match = feature as? T {
                return match
            }
            
            if let collection = feature as? KMLFeatureCollection {
                if let match = collection.findFirstFeature(ofType: type) {
                    return match
                }
            }
            
        }
        return nil
    }
    
}

extension KMLContainer: Collection {
    
    public typealias Element = KMLFeature
    public typealias Iterator = Array<Element>.Iterator
    public typealias Index = Array<Element>.Index
    
    public var startIndex: Array<Element>.Index { features.startIndex }
    public var endIndex: Array<Element>.Index { features.endIndex }
    public subscript(position: Array<Element>.Index) -> KMLFeature { features[position] }
    public func index(after i: Array<Element>.Index) -> Array<Element>.Index { features.index(after: i) }
    public func makeIterator() -> Iterator { return features.makeIterator() }
}

#if os(macOS)
extension KMLContainer {

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        for child in features {
            addChild(to: element, child: child, in: doc)
        }
    }

}
#endif

/**
 A Folder is used to arrange other Features hierarchically (Folders, Placemarks, NetworkLinks, or Overlays). A Feature is visible only if it and all its ancestors are visible.
 */
open class KMLFolder: KMLContainer {
}
