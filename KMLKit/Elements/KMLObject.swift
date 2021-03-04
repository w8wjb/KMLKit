//
//  AbstractObject.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

open class KMLObject: NSObject {
    @objc open var id: String?
    @objc open var name: String?
    @objc open var targetId: String?
    
    public override init() {
        super.init()
    }

    public init(_ attributes: [String:String]) {
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
    
    internal func toElement() -> XMLElement {
        let element = XMLElement(name: type(of: self).elementName)
        addAttribute(to: element, withName: "id", value: id)
        addAttribute(to: element, withName: "name", value: name)
        addAttribute(to: element, withName: "targetId", value: targetId)
        return element
    }
}
#endif
