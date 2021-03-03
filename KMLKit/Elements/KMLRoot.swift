//
//  Kml.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

open class KMLRoot: NSObject, KMLFeatureCollection {
    
    @objc open var name: String?
    @objc open var hint: String?
    @objc open var networkLinkControl: KMLNetworkLinkControl?
    @objc open var feature: KMLFeature?

    open func add(feature: KMLFeature) {
        self.feature = feature
    }

    open func findFeatures<T:KMLFeature>(ofType type: T.Type) -> [T] {
        
        var found: [T] = []
        
        if let myFeature = self.feature as? T {
            found.append(myFeature)
        }
        
        if let collection = self.feature as? KMLFeatureCollection {
            found.append(contentsOf: collection.findFeatures(ofType: type))
        }
        
        return found
    }
    
    open func findFirstFeature<T>(ofType type: T.Type) -> T? {
        
        if let match = feature as? T {
            return match
        }
        
        if let collection = self.feature as? KMLFeatureCollection {
            if let match = collection.findFirstFeature(ofType: type) {
                return match
            }
        }
        return nil
    }
    
    
    
}
