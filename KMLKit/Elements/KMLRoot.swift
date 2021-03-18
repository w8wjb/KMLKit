//
//  Kml.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

open class KMLRoot: NSObject, KMLFeatureCollection {
    
    @objc open var name: String?
    /** The hint attribute is used as a signal to Google Earth to display the file as celestial data. */
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

#if os(macOS)
extension KMLRoot: KMLWriterNode {
    static let elementName = "kml"
    
    func toElement(in doc: XMLDocument) -> XMLElement {
        let element = XMLElement(name: type(of: self).elementName)
        
        let nsXSI = XMLNode.namespace(withName: "xsi", stringValue: "http://www.w3.org/2001/XMLSchema-instance") as! XMLNode
        element.addNamespace(nsXSI)

        let ns = XMLNode.namespace(withName: "", stringValue: "http://www.opengis.net/kml/2.2") as! XMLNode
        element.addNamespace(ns)
        
        let schemaLocations = XMLNode.attribute(withName: "xsi:schemaLocation", stringValue: "http://www.opengis.net/kml/2.2 http://schemas.opengis.net/kml/2.3/ogckml23.xsd") as! XMLNode
        element.addAttribute(schemaLocations)
        
        doc.addChild(element)
        
        addChild(to: element, child: self.networkLinkControl, in: doc)
        addChild(to: element, child: self.feature, in: doc)

        return element
    }
}
#endif
