//
//  Link.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class KMLBasicLink: KMLObject {
    @objc var href: URL?
    
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


public class KMLLink: KMLBasicLink {

    @objc public var rel: String?
    @objc public var type: String?
    @objc public var hreflang: String?
    @objc public var title: String?
    @objc public var length: Int = 0
    @objc public var refreshMode = KMLRefreshMode.onChange
    @objc public var refreshInterval: Double = 4.0
    @objc public var viewRefreshMode = KMLViewRefreshMode.never
    @objc public var viewRefreshTime: Double = 4.0
    @objc public var viewBoundScale: Double = 1.0
    @objc public var viewFormat: String?
    @objc public var httpQuery: String?
    
    
    @objc public enum KMLRefreshMode: Int {
        case onChange
        case onInterval
        case onExpire
        
        init(_ value: String) {
            switch value {
            case "onChange":
                self = .onChange
            case "onInterval":
                self = .onInterval
            case "onExpire":
                self = .onExpire
            default:
                self = .onChange
            }
        }

    }
    
    
    @objc public enum KMLViewRefreshMode: Int {
        case never
        case onRequest
        case onStop
        case onRegion
        
        init(_ value: String) {
            switch value {
            case "never":
                self = .never
            case "onRequest":
                self = .onRequest
            case "onStop":
                self = .onStop
            case "onRegion":
                self = .onRegion
            default:
                self = .never
            }
        }
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
            self.length = Int(length) ?? 0
        }
    }
    
    public override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "refreshMode", let refreshMode = value as? KMLRefreshMode {
            self.refreshMode = refreshMode
        } else if key == "viewRefreshMode", let viewRefreshMode = value as? KMLViewRefreshMode {
            self.viewRefreshMode = viewRefreshMode
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
}


public class KMLIcon: KMLLink {

}
