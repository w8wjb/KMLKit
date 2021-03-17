//
//  Snippet.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

open class KMLSnippet: NSObject {
    @objc open var value: String?
    @objc open var maxLines: Int = 2
    
    public override init() {
        super.init()
    }
    
    init(_ attributes: [String:String]) {
        self.maxLines =  Int(attributes["maxLines"] ?? "2") ?? 2
    }
}

#if os(macOS)
extension KMLSnippet: KMLWriterNode {
    static let elementName = "Snippet"
    
    func toElement(in doc: XMLDocument) -> XMLElement {
        let element = XMLElement(name: Swift.type(of: self).elementName)
        
        if maxLines != 2 {
            let attr = XMLNode.attribute(withName: "maxLines", stringValue: String(maxLines)) as! XMLNode
            element.addAttribute(attr)
        }
        element.setStringValue(value ?? "", resolvingEntities: false)        
        return element
    }
}
#endif
