//
//  AtomLink.swift
//  KMLKitTests
//
//  Created by Weston Bustraan on 3/2/21.
//

import Foundation

open class AtomLink: NSObject, KMLAbstractLink {
    
    @objc open var href: URL?
    @objc open var rel: String?
    @objc open var type: String?
    @objc open var hreflang: String?
    @objc open var title: String?
    @objc open var length: Int = 0
    
    public init(href: URL) {
        self.href = href
        super.init()
    }


    public convenience init(href: URL, _ attributes: [String : String]) {
        self.init(href: href)
    }
}


#if os(macOS)
extension AtomLink: KMLWriterNode {
    static let elementName = "author"
    
    func toElement(in doc: XMLDocument) -> XMLElement {        
        let element = XMLElement(name: Swift.type(of: self).elementName)
        element.addNamespace(XMLNode.namespace(withName: "atom", stringValue: "http://www.w3.org/2005/Atom") as! XMLNode)

        if let href = self.href {
            addAttribute(to: element, withName: "href", value: href.description)
        }
        addAttribute(to: element, withName: "rel", value: rel)
        addAttribute(to: element, withName: "type", value: type)
        addAttribute(to: element, withName: "hreflang", value: hreflang)
        addAttribute(to: element, withName: "title", value: title)
        if length > 0 {
            addAttribute(to: element, withName: "length", value: String(length))
        }
        
        return element
    }
}
#endif
