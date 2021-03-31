//
//  KMLSchema.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/28/21.
//

import Foundation

/**
 Specifies a custom KML schema that is used to add custom data to KML Features. The "id" attribute is required and must be unique within the KML file. &lt;Schema&gt; is always a child of &lt;Document&gt;.
 */
open class KMLSchema: NSObject {
        
    @objc open var id: String?
    @objc open var name: String?
    
    /**
     A Schema element contains one or more SimpleField elements. In the SimpleField, the Schema declares the type and name of the custom field. It optionally specifies a displayName (the user-friendly form, with spaces and proper punctuation used for display in Google Earth) for this custom field.
     */
    @objc open var fields: [KMLSimpleField] = []

    
    public override init() {
        super.init()
    }

    internal init(_ attributes: [String:String]) {
        self.id = attributes["id"]
        self.name = attributes["name"]
    }

}

#if os(macOS)
extension KMLSchema: KMLWriterNode {
    static let elementName = "kml"
    
    func toElement(in doc: XMLDocument) -> XMLElement {
        let element = XMLElement(name: type(of: self).elementName)
        if let id = self.id {
            let idAttr = XMLNode.attribute(withName: "id", stringValue: id) as! XMLNode
            element.addAttribute(idAttr)
        }
        
        if let name = self.name {
            let idAttr = XMLNode.attribute(withName: "name", stringValue: name) as! XMLNode
            element.addAttribute(idAttr)
        }
        
        for child in fields {
            addChild(to: element, child: child, in: doc)
        }

        return element
    }
}
#endif
