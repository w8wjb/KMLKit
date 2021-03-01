//
//  KMLSimpleField.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/28/21.
//

import Foundation

public class KMLSimpleField: NSObject {
    
    @objc public var type: String?
    @objc public var name: String?
    @objc public var uom: URL?
    @objc public var displayName: String?

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


public class KMLSimpleArrayField: KMLSimpleField {
    
}
