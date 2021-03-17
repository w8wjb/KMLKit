//
//  KMLSimpleField.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/28/21.
//

import Foundation

open class KMLSimpleField: NSObject {
    
    /**
     Type of field
     
     The type can be one of the following:
     - string
     - int
     - uint
     - short
     - ushort
     - float
     - double
     - bool
     */
    @objc open var type: String?
    @objc open var name: String?
    @objc open var uom: URL?
    /** The name, if any, to be used when the field name is displayed to the Google Earth user. Use the [CDATA] element to escape standard HTML markup. */
    @objc open var displayName: String?
    
    public override init() {
        super.init()
    }
    
    public init(_ attributes: [String:String]) {
        self.type = attributes["type"]
        self.name = attributes["name"]
        if let uom = attributes["uom"] {
            self.uom = URL(string: uom)
        }
    }
}

#if os(macOS)
extension KMLSimpleField: KMLWriterNode {
    static let elementName = "SimpleField"
    
    func toElement(in doc: XMLDocument) -> XMLElement {
        let element = XMLElement(name: Swift.type(of: self).elementName)
        if let type = self.type {
            let attr = XMLNode.attribute(withName: "type", stringValue: type) as! XMLNode
            element.addAttribute(attr)
        }
        
        if let name = self.name {
            let attr = XMLNode.attribute(withName: "name", stringValue: name) as! XMLNode
            element.addAttribute(attr)
        }
        
        if let uom = self.uom {
            let attr = XMLNode.attribute(withName: "uom", stringValue: uom.description) as! XMLNode
            element.addAttribute(attr)
        }
        
        addSimpleChild(to: element, withName: "displayName", value: displayName)        
        return element
    }
}
#endif


open class KMLSimpleArrayField: KMLSimpleField {
    
}
