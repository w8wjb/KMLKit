//
//  KMLWriter.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/26/21.
//

import Foundation
import CoreLocation


@objc internal protocol KMLWriterNode: class {
    
    static var elementName: String { get }
    
    func toElement(in doc: XMLDocument)-> XMLElement
}

internal extension KMLWriterNode {
    
    func addAttribute(to parent: XMLElement, withName name: String, value inValue: String?) {
        guard let value = inValue else { return }
        parent.addAttribute(XMLNode.attribute(withName: name, stringValue: value) as! XMLNode)
    }
    
    func addSimpleChild(to parent: XMLElement, withName name: String, value inValue: String?, default defaultValue: String? = nil) {
        guard let value = inValue else { return }
        if let defaultValue = defaultValue, defaultValue == value { return }
        
        if value.contains("<") {
            let textNode = XMLNode(kind: .text, options: .nodeIsCDATA)
            textNode.setStringValue(value, resolvingEntities: false)
            let childNode = XMLNode.element(withName: name, children: [textNode], attributes: nil) as! XMLNode
            parent.addChild(childNode)
        } else {
            parent.addChild(XMLNode.element(withName: name, stringValue: value) as! XMLNode)
        }
        
    }

    func addSimpleChild(to parent: XMLElement, withName name: String, value inValue: URL?) {
        guard let value = inValue else { return }
        parent.addChild(XMLNode.element(withName: name, stringValue: value.description) as! XMLNode)
    }

    func addSimpleChild<T:BinaryInteger>(to parent: XMLElement, withName name: String, value inValue: T?, default defaultValue: T? = nil) {
        guard let value = inValue else { return }
        if let defaultValue = defaultValue, defaultValue == value { return }
        parent.addChild(XMLNode.element(withName: name, stringValue: "\(value)") as! XMLNode)
    }

    func addSimpleChild<T:BinaryFloatingPoint>(to parent: XMLElement, withName name: String, value inValue: T?, default defaultValue: T? = nil) {
        guard let value = inValue else { return }
        if let defaultValue = defaultValue, defaultValue == value { return }
        parent.addChild(XMLNode.element(withName: name, stringValue: "\(value)") as! XMLNode)
    }

    func addSimpleChild(to parent: XMLElement, withName name: String, value inValue: Date?) {
        guard let value = inValue else { return }
        parent.addChild(XMLNode.element(withName: name, stringValue: KMLTimeStamp.dateTimeFormatter.string(from: value)) as! XMLNode)
    }

    func addSimpleChild(to parent: XMLElement, withName name: String, value inValue: Bool, numeric: Bool = false, default defaultValue: Bool? = nil) {
        let value: String
        if numeric {
            value = inValue ? "1" : "0"
        } else {
            value = inValue ? "true" : "false"
        }
        if let defaultValue = defaultValue, defaultValue == inValue { return }
        parent.addChild(XMLNode.element(withName: name, stringValue: value) as! XMLNode)
    }
    
    func addSimpleChild(to parent: XMLElement, withName name: String, value inValue: CGPoint?, units: String = "fraction") {
        guard let value = inValue else { return }
        let xAttr = XMLNode.attribute(withName: "x", stringValue: String(Double(value.x))) as! XMLNode
        let yAttr = XMLNode.attribute(withName: "y", stringValue: String(Double(value.y))) as! XMLNode
        var attrs = [xAttr, yAttr]
        if units != "fraction" {
            let xunitsAttr = XMLNode.attribute(withName: "xunits", stringValue: units) as! XMLNode
            attrs.append(xunitsAttr)
            let yunitsAttr = XMLNode.attribute(withName: "yunits", stringValue: units) as! XMLNode
            attrs.append(yunitsAttr)
        }
        let childElement = XMLNode.element(withName: name, children: nil, attributes: attrs) as! XMLNode
        parent.addChild(childElement)
    }
    
    func addSimpleChild(to parent: XMLElement, withName name: String, value inValue: CGSize?, units: String = "fraction") {
        guard let value = inValue else { return }
        let xAttr = XMLNode.attribute(withName: "x", stringValue: String(Double(value.width))) as! XMLNode
        let yAttr = XMLNode.attribute(withName: "y", stringValue: String(Double(value.height))) as! XMLNode
        var attrs = [xAttr, yAttr]
        if units != "fraction" {
            let xunitsAttr = XMLNode.attribute(withName: "xunits", stringValue: units) as! XMLNode
            attrs.append(xunitsAttr)
            let yunitsAttr = XMLNode.attribute(withName: "yunits", stringValue: units) as! XMLNode
            attrs.append(yunitsAttr)
        }
        let childElement = XMLNode.element(withName: name, children: nil, attributes: attrs) as! XMLNode
        parent.addChild(childElement)
    }
    
    func addChild(to parent: XMLElement, child inChild: AnyObject?, in doc: XMLDocument) {
        guard let child = inChild as? KMLWriterNode else { return }
        let childElement = child.toElement(in: doc)
        parent.addChild(childElement)
    }
    
    
    func formatAsLonLatAlt(_ location: CLLocation) -> String {
        if location.altitude >= 0 {
            return "\(location.coordinate.longitude),\(location.coordinate.latitude),\(location.altitude)"
        } else {
            return "\(location.coordinate.longitude),\(location.coordinate.latitude)"
        }
    }
    
    func formatAsLonLatAlt(_ locations: [CLLocation]) -> String {
        return locations.compactMap(self.formatAsLonLatAlt).joined(separator: " ")
    }
    
}

open class KMLWriter {
    
    open func write(kml: KMLRoot, to outputFile: URL) throws {
        
        let doc = XMLDocument()
        let root = kml.toElement(in: doc)
        doc.setRootElement(root)
        
        let data = doc.xmlData(options: .nodePrettyPrint)
        try data.write(to: outputFile)
        
    }
    
}
