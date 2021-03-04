//
//  KMLWriter.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/26/21.
//

import Foundation


@objc internal protocol KMLWriterNode: class {
    
    static var elementName: String { get }
    
    func toElement() -> XMLElement
}

internal extension KMLWriterNode {
    
    func addAttribute(to parent: XMLElement, withName name: String, value inValue: String?) {
        guard let value = inValue else { return }
        parent.addAttribute(XMLNode.attribute(withName: name, stringValue: value) as! XMLNode)
    }
    
    func addSimpleChild(to parent: XMLElement, withName name: String, value inValue: String?) {
        guard let value = inValue else { return }
        parent.addChild(XMLNode.element(withName: name, stringValue: value) as! XMLNode)
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
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = .withInternetDateTime
        parent.addChild(XMLNode.element(withName: name, stringValue: dateFormatter.string(from: value)) as! XMLNode)
    }

    func addChild(to parent: XMLElement, child inChild: KMLWriterNode?) {
        guard let child = inChild else { return }
        let childElement = child.toElement()
        parent.addChild(childElement)
    }
    
}

open class KMLWriter {
    
    open func write(kml: KMLRoot, to: URL) {
        
        let root = kml.toElement()
        let doc = XMLDocument(rootElement: root)
        
        print(doc.xmlString(options: .nodePrettyPrint))
        
    }
    
}
