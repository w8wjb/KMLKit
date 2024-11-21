//
//  NetworkLinkControl.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

/**
 Controls the behavior of files fetched by a &lt;NetworkLink&gt;.
 */
open class KMLNetworkLinkControl: NSObject {
    
    /**
     Specified in seconds, &lt;minRefreshPeriod&gt; is the minimum allowed time between fetches of the file. This parameter allows servers to throttle fetches of a particular file and to tailor refresh rates to the expected rate of change to the data. For example, a user might set a link refresh to 5 seconds, but you could set your minimum refresh period to 3600 to limit refresh updates to once every hour.
     */
    @objc open var minRefreshPeriod: Float = 0
    
    /** Specified in seconds, &lt;maxSessionLength&gt; is the maximum amount of time for which the client NetworkLink can remain connected. The default value of -1 indicates not to terminate the session explicitly. */
    @objc open var maxSessionLength: Float = -1
    
    /** Use this element to append a string to the URL query on the next refresh of the network link. You can use this data in your script to provide more intelligent handling on the server side, including version querying and conditional file delivery. */
    @objc open var cookie: String?
    
    /** You can deliver a pop-up message, such as usage guidelines for your network link. The message appears when the network link is first loaded into Google Earth, or when it is changed in the network link control. */
    @objc open var message: String?
    
    /** You can control the name of the network link from the server, so that changes made to the name on the client side are overridden by the server. */
    @objc open var linkName: String?
    
    /** You can control the description of the network link from the server, so that changes made to the description on the client side are overridden by the server. */
    @objc open var linkDescription: String?
    
    /** You can control the snippet for the network link from the server, so that changes made to the snippet on the client side are overridden by the server. &lt;linkSnippet&gt; has a maxLines attribute, an integer that specifies the maximum number of lines to display. */
    @objc open var linkSnippet: String?
    
    /** Specifies the maximum number of lines to display */
    @objc open var linkSnippetMaxLines: Int = -1
    
    /** You can specify a date/time at which the link should be refreshed. This specification takes effect only if the &lt;refreshMode&gt; in &lt;Link&gt; has a value of **onExpire**. */
    @objc open var expires: Date?
    
    @objc open var update: KMLUpdate?
    @objc open var view: KMLAbstractView?
}


#if os(macOS)
extension KMLNetworkLinkControl: KMLWriterNode {
    
    class var elementName: String { "NetworkLinkControl" }

    func toElement(in doc: XMLDocument) -> XMLElement {
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
        addChild(to: element, child: update, in: doc)
        addChild(to: element, child: view, in: doc)
        
        return element
    }
}
#endif
