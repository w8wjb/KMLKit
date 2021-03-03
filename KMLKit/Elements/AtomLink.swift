//
//  AtomLink.swift
//  KMLKitTests
//
//  Created by Weston Bustraan on 3/2/21.
//

import Foundation

open class AtomLink: NSObject {
    
    @objc open var href: URL
    @objc open var rel: String?
    @objc open var type: String?
    @objc open var hreflang: String?
    @objc open var title: String?
    @objc open var length: Int = 0
    
    public init(href: URL) {
        self.href = href
        super.init()
    }


    public convenience init(href: URL, _ attributes: [String : String]) {
        self.init(href: href)
    }
}
