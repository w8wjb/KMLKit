//
//  Container.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public protocol KMLFeatureCollection {
    
    func findFirstFeatures<T>(ofType type: T.Type) -> T?
    func findFeatures<T:KMLFeature>(ofType type: T.Type) -> [T]
}


public class KMLContainer: KMLFeature, KMLFeatureCollection {

    var features: [KMLFeature] = []
    
    public func findFeatures<T:KMLFeature>(ofType type: T.Type) -> [T] {
        
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

    
    public func findFirstFeatures<T>(ofType type: T.Type) -> T? {
        
        for feature in self {
            if let match = feature as? T {
                return match
            }
            
            if let collection = feature as? KMLFeatureCollection {
                if let match = collection.findFirstFeatures(ofType: type) {
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




public class KMLFolder: KMLContainer {
}

public class KMLDocument: KMLContainer {
    
}