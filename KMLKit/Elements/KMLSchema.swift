//
//  KMLSchema.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/28/21.
//

import Foundation

public class KMLSchema: NSObject {
        
    @objc public var id: String?
    @objc public var name: String?
    @objc public var fields: [KMLSimpleField] = []

    
    public override init() {
        super.init()
    }

    public init(_ attributes: [String:String]) {
        self.id = attributes["id"]
        self.name = attributes["name"]
    }

}
