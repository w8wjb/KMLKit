//
//  Author.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class Author {
    public var nameOrUriOrEmail = [String]()
    
    init() {
        
    }
    
    init(name: String) {
        nameOrUriOrEmail = [name]
    }
    
}
