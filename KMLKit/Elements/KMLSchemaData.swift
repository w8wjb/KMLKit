//
//  KMLSchemaData.swift
//  KMLKit
//
//  Created by Weston Bustraan on 3/1/21.
//

import Foundation

/**
 This element is used in conjunction with &lt;Schema&gt; to add typed custom data to a KML Feature. The Schema element (identified by the schemaUrl attribute) declares the custom data type. The actual data objects ("instances" of the custom data) are defined using the SchemaData element.
 
 The &lt;schemaURL&gt; can be a full URL, a reference to a Schema ID defined in an external KML file, or a reference to a Schema ID defined in the same KML file. All of the following specifications are acceptable:
 
 The Schema element is always a child of Document. The ExtendedData element is a child of the Feature that contains the custom data.
 */
open class KMLSchemaData: KMLObject, KMLSimpleData {
    /** This element assigns a value to the custom data field identified by the name attribute. The type and name of this custom data field are declared in the &lt;Schema&gt; element. */
    open var data: [String : Any] = [:]
}

#if os(macOS)
extension KMLSchemaData {

    override func toElement(in doc: XMLDocument) -> XMLElement {
        let element = super.toElement(in: doc)
        
        for (key, value) in data {
            
            let nameAttr = XMLNode.attribute(withName: "name", stringValue: key) as! XMLNode
            if let array = value as? Array<Any> {
                let childElement = XMLElement(name: "SimpleArrayData")
                childElement.addAttribute(nameAttr)
                
                for item in array {
                    addSimpleChild(to: childElement, withName: "value", value: "\(item)")
                }

            } else {
                let childElement = XMLElement(name: "SimpleData")
                childElement.addAttribute(nameAttr)
                childElement.setStringValue("\(value)", resolvingEntities: false)
                element.addChild(childElement)
            }
        }
        
        return element
    }
}
#endif
