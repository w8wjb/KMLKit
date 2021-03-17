//
//  Author.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

open class AtomAuthor: NSObject {
    @objc open var name: [String] = []
    @objc open var uri: [URL] = []
    @objc open var email: [String] = []
    
    override init() {
        super.init()
    }
    
    init(name: String) {
        self.name = [name]
    }
    
    open override func setValue(_ value: Any?, forKey key: String) {
        if key == "name", let name = value as? String {
            self.name.append(name)
        } else if key == "uri", let uri = value as? URL {
            self.uri.append(uri)
        } else if key == "email", let email = value as? String {
            self.email.append(email)
        } else {
            super.setValue(value, forKey: key)
        }
    }
    
}

#if os(macOS)
extension AtomAuthor: KMLWriterNode {
    static let elementName = "atom:author"
    
    func toElement(in doc: XMLDocument) -> XMLElement {
        let element = XMLElement(name: type(of: self).elementName)
        element.addNamespace(XMLNode.namespace(withName: "atom", stringValue: "http://www.w3.org/2005/Atom") as! XMLNode)
        
        for child in name {
            addSimpleChild(to: element, withName: "atom:name", value: child)
        }
        for child in email {
            addSimpleChild(to: element, withName: "atom:email", value: child)
        }
        for child in uri {
            addSimpleChild(to: element, withName: "atom:uri", value: child)
        }

        return element
    }
}
#endif
