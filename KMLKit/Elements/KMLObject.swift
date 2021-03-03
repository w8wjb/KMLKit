//
//  AbstractObject.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

open class KMLObject: NSObject {
    @objc open var id: String?
    @objc open var name: String?
    @objc open var targetId: String?
    
    
    public override init() {
        super.init()
    }

    public init(_ attributes: [String:String]) {
        self.id = attributes["id"]
        self.targetId = attributes["targetId"]
    }
}
