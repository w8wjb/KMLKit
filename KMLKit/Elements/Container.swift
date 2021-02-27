//
//  Container.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public protocol FeatureCollection {
    
    func findFirstFeatures<T>(ofType type: T.Type) -> T?
    func findFeatures<T:Feature>(ofType type: T.Type) -> [T]
}


public class Container: Feature, FeatureCollection {

    var features: [Feature] = []
    
    public func findFeatures<T:Feature>(ofType type: T.Type) -> [T] {
        
        var found: [T] = []
        
        for feature in self {
            
            if let match = feature as? T {
                found.append(match)
            }
            
            if let collection = feature as? FeatureCollection {
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
            
            if let collection = feature as? FeatureCollection {
                if let match = collection.findFirstFeatures(ofType: type) {
                    return match
                }
            }
            
        }
        return nil
    }
    
}

extension Container: Collection {
    
    public typealias Element = Feature
    public typealias Iterator = Array<Element>.Iterator
    public typealias Index = Array<Element>.Index
    
    public var startIndex: Array<Element>.Index { features.startIndex }
    public var endIndex: Array<Element>.Index { features.endIndex }
    public subscript(position: Array<Element>.Index) -> Feature { features[position] }
    public func index(after i: Array<Element>.Index) -> Array<Element>.Index { features.index(after: i) }
    public func makeIterator() -> Iterator { return features.makeIterator() }
}




public class Folder: Container {
}

public class Document: Container {
    
}
