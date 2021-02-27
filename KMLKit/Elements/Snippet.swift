//
//  Snippet.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public struct Snippet {
    public var value: String?
    public var maxLines: Int = 2
    
    public init() {
        
    }
    
    init(_ attributes: [String:String]) {
        self.maxLines =  Int(attributes["maxLines"] ?? "2") ?? 2
    }
}
