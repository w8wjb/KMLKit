//
//  AbstractObject.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class KMLObject: NSObject {
    public var id: String?
    public var name: String?
    public var targetId: String?
    
    
    public override init() {
        super.init()
    }

    public init(_ attributes: [String:String]) {
        self.id = attributes["id"]
        self.targetId = attributes["targetId"]
    }
}
