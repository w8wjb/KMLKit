//
//  Link.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class BasicLink: KmlObject {
    var href: URL?
    
    public override init() {
        super.init()
    }

    public init(href: String) {
        super.init()
        self.href = URL(string: href)
    }
    
    public init(href: URL) {
        super.init()
        self.href = href
    }


    public override init(_ attributes: [String : String]) {
        super.init(attributes)
    }
    
}


public class Link: BasicLink {

    public var rel: String?
    public var type: String?
    public var hreflang: String?
    public var title: String?
    public var length: Int?
    public var refreshMode = RefreshMode.onChange
    public var refreshInterval: Double = 4.0
    public var viewRefreshMode = ViewRefreshMode.never
    public var viewRefreshTime: Double = 4.0
    public var viewBoundScale: Double = 1.0
    public var viewFormat: String?
    public var httpQuery: String?
    
    
    public enum RefreshMode: String {
        case onChange = "onChange"
        case onInterval = "onInterval"
        case onExpire = "onExpire"
    }
    
    
    public enum ViewRefreshMode: String {
        case never = "never"
        case onRequest = "onRequest"
        case onStop = "onStop"
        case onRegion = "onRegion"
    }
    
    
    public override init() {
        super.init()
    }
    
    public override init(href: String) {
        super.init(href: href)
    }
    
    public override init(href: URL) {
        super.init(href: href)
    }
    
    public override init(_ attributes: [String:String]) {
        super.init(attributes)
        if let href = attributes["href"] {
            self.href = URL(string: href)
        }
        self.rel = attributes["rel"]
        self.type = attributes["type"]
        self.hreflang = attributes["hreflang"]
        self.title = attributes["title"]
        if let length = attributes["length"] {
            self.length = Int(length)
        }
    }
}


public class Icon: Link {

}
