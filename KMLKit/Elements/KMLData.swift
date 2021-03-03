//
//  KMLExtendedData.swift
//  KMLKit
//
//  Created by Weston Bustraan on 3/1/21.
//

import Foundation


open class KMLData: KMLObject {
    
    @objc open var value: Any?
    @objc open var type: String?
    @objc open var uom: URL?
    @objc open var displayName: String?

    public override init() {
        super.init()
    }

    public override init(_ attributes: [String:String]) {
        super.init(attributes)
        self.type = attributes["type"]
        if let uom = attributes["uom"] {
            self.uom = URL(string: uom)
        }
    }

    
}

open class KMLExtendedData: NSObject {
    @objc open var data: [KMLData] = []
    @objc open var schemaData: [KMLSchemaData] = []
}
