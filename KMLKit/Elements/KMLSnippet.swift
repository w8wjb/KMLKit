//
//  Snippet.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

open class KMLSnippet: NSObject {
    @objc open var value: String?
    @objc open var maxLines: Int = 2
    
    public override init() {
        super.init()
    }
    
    init(_ attributes: [String:String]) {
        self.maxLines =  Int(attributes["maxLines"] ?? "2") ?? 2
    }
}
