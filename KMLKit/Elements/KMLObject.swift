//
//  AbstractObject.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

/**
 This is an abstract base class and cannot be used directly in a KML file. It provides the **id** attribute, which allows unique identification of a KML element, and the **targetId** attribute, which is used to reference objects that have already been loaded into Google Earth. The id attribute must be assigned if the &lt;Update&gt; mechanism is to be used.
 */
open class KMLObject: NSObject {
    @objc open var id: String?
    @objc open var name: String?
    @objc open var targetId: String?
    
    public override init() {
        super.init()
    }
    
    public init(id: String) {
        self.id = id
        super.init()
    }

    internal init(_ attributes: [String:String]) {
        self.id = attributes["id"]
        self.targetId = attributes["targetId"]
    }
}

#if os(macOS)
@objc extension KMLObject: KMLWriterNode {
    
    class var elementName: String {
        let className = String(describing: self).dropFirst(3)
        return String(className)
    }
    
    internal func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        addAttribute(to: element, withName: "id", value: id)
        addAttribute(to: element, withName: "targetId", value: targetId)
        addSimpleChild(to: element, withName: "name", value: name)
    }
    
    internal func toElement(in doc: XMLDocument) -> XMLElement {
        let element = XMLElement(name: type(of: self).elementName)
        addChildNodes(to: element, in: doc)
        return element
    }
}
#endif
