//
//  Author.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class KMLAuthor: NSObject {
    public var nameOrUriOrEmail = [String]()
    
    override init() {
        super.init()
    }
    
    init(name: String) {
        nameOrUriOrEmail = [name]
    }
    
}
