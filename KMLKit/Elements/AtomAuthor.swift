//
//  Author.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

open class AtomAuthor: NSObject {
    @objc open var name: [String] = []
    @objc open var uri: [URL] = []
    @objc open var email: [String] = []
    
    override init() {
        super.init()
    }
    
    init(name: String) {
        self.name = [name]
    }
    
    open override func setValue(_ value: Any?, forKey key: String) {
        if key == "name", let name = value as? String {
            self.name.append(name)
        } else if key == "uri", let uri = value as? URL {
            self.uri.append(uri)
        } else if key == "email", let email = value as? String {
            self.email.append(email)
        } else {
            super.setValue(value, forKey: key)
        }
    }
    
}
