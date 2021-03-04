//
//  NetworkLinkControl.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

open class KMLNetworkLinkControl: NSObject {
    @objc open var minRefreshPeriod: Float = 0
    @objc open var maxSessionLength: Float = -1
    @objc open var cookie: String?
    @objc open var message: String?
    @objc open var linkName: String?
    @objc open var linkDescription: String?
    @objc open var linkSnippet: String?
    @objc open var linkSnippetMaxLines: Int = -1
    @objc open var expires: Date?
    @objc open var update: KMLUpdate?
    @objc open var view: KMLAbstractView?
}


#if os(macOS)
extension KMLNetworkLinkControl: KMLWriterNode {
    
    class var elementName: String { "NetworkLinkControl" }

    func toElement() -> XMLElement {
        let element = XMLElement(name: type(of: self).elementName)

        addSimpleChild(to: element, withName: "minRefreshPeriod", value: minRefreshPeriod, default: 0)
        addSimpleChild(to: element, withName: "maxSessionLength", value: maxSessionLength, default: -1)
        addSimpleChild(to: element, withName: "cookie", value: cookie)
        addSimpleChild(to: element, withName: "message", value: message)
        addSimpleChild(to: element, withName: "linkName", value: linkName)
        addSimpleChild(to: element, withName: "linkDescription", value: linkDescription)
        
        
        if let linkSnippet = self.linkSnippet {
            let child = XMLElement(name: "linkSnippet", stringValue: linkSnippet)
            if linkSnippetMaxLines != -1 {
                child.addAttribute(XMLNode.attribute(withName: "maxLines", stringValue: String(linkSnippetMaxLines)) as! XMLNode)
            }
            element.addChild(child)
        }
        
        addSimpleChild(to: element, withName: "expires", value: expires)
        addChild(to: element, child: update)
        addChild(to: element, child: view)
        
        return element
    }
}
#endif
