//
//  KMLExtendedData.swift
//  KMLKit
//
//  Created by Weston Bustraan on 3/1/21.
//

import Foundation


public class KMLData: KMLObject {
    
    @objc public var value: Any?
    @objc public var type: String?
    @objc public var uom: URL?
    @objc public var displayName: String?

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

public class KMLExtendedData: NSObject {
    @objc public var data: [KMLData] = []
    @objc public var schemaData: [KMLSchemaData] = []
}
