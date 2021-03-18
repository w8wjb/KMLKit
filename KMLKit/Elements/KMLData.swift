//
//  KMLExtendedData.swift
//  KMLKit
//
//  Created by Weston Bustraan on 3/1/21.
//

import Foundation

/**
 Creates an untyped name/value pair. The name can have two versions: name and displayName. The name attribute is used to identify the data pair within the KML file. The displayName element is used when a properly formatted name, with spaces and HTML formatting, is displayed in Google Earth. In the &lt;text&gt; element of &lt;BalloonStyle&gt;, the notation $[name/displayName] is replaced with &lt;displayName&gt;. If you substitute the value of the name attribute of the &lt;Data&gt; element in this format (for example, $[holeYardage], the attribute value is replaced with &lt;value&gt;. By default, the Placemark's balloon displays the name/value pairs associated with it.
 */
open class KMLData: KMLObject {
    
    @objc open var value: Any?
    @objc open var type: String?
    @objc open var uom: URL?
    /** An optional formatted version of name, to be used for display purposes. */
    @objc open var displayName: String?

    public override init() {
        super.init()
    }

    public override init(_ attributes: [String:String]) {
        super.init(attributes)
        self.type = attributes["type"]
        if let uom = attributes["uom"] {
            self.uom = URL(string: uom)
        }
    }
}

#if os(macOS)
extension KMLData {
    
    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        
        if let name = self.name {
            let nameAttr = XMLNode.attribute(withName: "name", stringValue: name) as! XMLNode
            element.addAttribute(nameAttr)
        }

        if let uom = self.uom {
            let nameAttr = XMLNode.attribute(withName: "uom", stringValue: uom.description) as! XMLNode
            element.addAttribute(nameAttr)
        }
        
        addSimpleChild(to: element, withName: "displayName", value: displayName)
        if let value = value {
            addSimpleChild(to: element, withName: "value", value: "\(value)")
        }

    }

}
#endif


/**
 The ExtendedData element offers three techniques for adding custom data to a KML Feature (NetworkLink, Placemark, GroundOverlay, PhotoOverlay, ScreenOverlay, Document, Folder). These techniques are

 - Adding untyped data/value pairs using the &lt;Data&gt; element (basic)
 - Declaring new typed fields using the &lt;Schema&gt; element and then instancing them using the &lt;SchemaData&gt; element (advanced)
 - Referring to XML elements defined in other namespaces by referencing the external namespace within the KML file (basic)
 These techniques can be combined within a single KML file or Feature for different pieces of data.

 For more information, see Adding Custom Data in "Topics in KML."
 */
open class KMLExtendedData: NSObject {
    @objc open var data: [KMLData] = []
    @objc open var schemaData: [KMLSchemaData] = []
}

#if os(macOS)
extension KMLExtendedData: KMLWriterNode {
    static let elementName = "ExtendedData"
    
    func toElement(in doc: XMLDocument) -> XMLElement {
        let element = XMLElement(name: type(of: self).elementName)
        for child in data {
            addChild(to: element, child: child, in: doc)
        }
        for child in schemaData {
            addChild(to: element, child: child, in: doc)
        }
        return element
    }
}
#endif
