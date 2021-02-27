//
//  Kml.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class KMLDocument: FeatureCollection {
    
    public var name: String?
    public var hint: String?
    public var networkLinkControl: NetworkLinkControl?
    public var feature: Feature?

    public func findFeatures<T:Feature>(ofType type: T.Type) -> [T] {
        
        var found: [T] = []
        
        if let myFeature = self.feature as? T {
            found.append(myFeature)
        }
        
        if let collection = self.feature as? FeatureCollection {
            found.append(contentsOf: collection.findFeatures(ofType: type))
        }
        
        return found
    }
    
    public func findFirstFeatures<T>(ofType type: T.Type) -> T? {
        
        if let match = feature as? T {
            return match
        }
        
        if let collection = self.feature as? FeatureCollection {
            if let match = collection.findFirstFeatures(ofType: type) {
                return match
            }
        }
        return nil
    }
    
    
    
}
