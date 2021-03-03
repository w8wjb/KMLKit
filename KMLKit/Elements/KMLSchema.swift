//
//  KMLSchema.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/28/21.
//

import Foundation

open class KMLSchema: NSObject {
        
    @objc open var id: String?
    @objc open var name: String?
    @objc open var fields: [KMLSimpleField] = []

    
    public override init() {
        super.init()
    }

    public init(_ attributes: [String:String]) {
        self.id = attributes["id"]
        self.name = attributes["name"]
    }

}
