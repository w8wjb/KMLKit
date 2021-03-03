//
//  KMLSimpleField.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/28/21.
//

import Foundation

open class KMLSimpleField: NSObject {
    
    @objc open var type: String?
    @objc open var name: String?
    @objc open var uom: URL?
    @objc open var displayName: String?

    public override init() {
        super.init()
    }

    public init(_ attributes: [String:String]) {
        self.type = attributes["type"]
        self.name = attributes["name"]
        if let uom = attributes["uom"] {
            self.uom = URL(string: uom)
        }
    }
}


open class KMLSimpleArrayField: KMLSimpleField {
    
}
