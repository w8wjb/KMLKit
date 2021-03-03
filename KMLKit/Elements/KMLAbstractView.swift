//
//  AbstractView.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

open class KMLAbstractView: KMLObject {
    
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
    
    @objc var time: KMLTimePrimitive?
    @objc var options: [ViewOption] = []
}

