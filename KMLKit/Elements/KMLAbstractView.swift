//
//  AbstractView.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

/**
 This is an abstract element and cannot be used directly in a KML file. This element is extended by the &lt;Camera&gt; and &lt;LookAt&gt; elements.
 */
open class KMLAbstractView: KMLObject {
    
    /**
     The &lt;gx:option&gt; element has a name attribute and an enabled attribute. The name specifies one of the following: Street View imagery ("streetview"), historical imagery ("historicalimagery"), and sunlight effects for a given time of day ("sunlight"). The enabled attribute is used to turn a given viewing mode on or off.
     */
    open class ViewOption: KMLObject {
        @objc open var enabled: Bool = true
        
        public override init() {
            super.init()
        }
        
        public override init(_ attributes: [String : String]) {
            super.init(attributes)
            self.name = attributes["name"]
            self.enabled = ((attributes["enabled"] ?? "true") as NSString).boolValue
        }
    }
    
    @objc open var time: KMLTimePrimitive?
    
    /** Enables special viewing modes in Google Earth 6.0 and later. It has one or more &lt;gx:option&gt; child elements.  */
    @objc open var options: [ViewOption] = []
}

#if os(macOS)
extension KMLAbstractView {

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        if let child = time as? KMLWriterNode {
            addChild(to: element, child: child, in: doc)
        }
    }
    
}
#endif
