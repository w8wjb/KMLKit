//
//  Kml.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class KMLRoot: NSObject, KMLFeatureCollection {
    
    public var name: String?
    public var hint: String?
    public var networkLinkControl: KMLNetworkLinkControl?
    public var feature: KMLFeature?

    public func findFeatures<T:KMLFeature>(ofType type: T.Type) -> [T] {
        
        var found: [T] = []
        
        if let myFeature = self.feature as? T {
            found.append(myFeature)
        }
        
        if let collection = self.feature as? KMLFeatureCollection {
            found.append(contentsOf: collection.findFeatures(ofType: type))
        }
        
        return found
    }
    
    public func findFirstFeatures<T>(ofType type: T.Type) -> T? {
        
        if let match = feature as? T {
            return match
        }
        
        if let collection = self.feature as? KMLFeatureCollection {
            if let match = collection.findFirstFeatures(ofType: type) {
                return match
            }
        }
        return nil
    }
    
    
    
}