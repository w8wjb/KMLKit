//
//  Author.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class KMLAuthor: NSObject {
    @objc public var nameOrUriOrEmail = [String]()
    
    override init() {
        super.init()
    }
    
    init(name: String) {
        nameOrUriOrEmail = [name]
    }
    
    public override func setValue(_ value: Any?, forKey key: String) {
        if key == "name", let name = value as? String {
            nameOrUriOrEmail.append(name)
        } else {
            super.setValue(value, forKey: key)
        }
    }
    
}
