//
//  Link.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

@objc public protocol KMLAbstractLink: class {
    var href: URL? { get set }
}

open class KMLBasicLink: KMLObject, KMLAbstractLink {
    @objc open var href: URL?
    
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


open class KMLLink: KMLBasicLink {

    @objc open var refreshMode = KMLRefreshMode.onChange
    @objc open var refreshInterval: Double = 4.0
    @objc open var viewRefreshMode = KMLViewRefreshMode.never
    @objc open var viewRefreshTime: Double = 4.0
    @objc open var viewBoundScale: Double = 1.0
    @objc open var viewFormat: String?
    @objc open var httpQuery: String?
    
    
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
    }
    
    open override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "refreshMode", let refreshMode = value as? KMLRefreshMode {
            self.refreshMode = refreshMode
        } else if key == "viewRefreshMode", let viewRefreshMode = value as? KMLViewRefreshMode {
            self.viewRefreshMode = viewRefreshMode
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
}


open class KMLIcon: KMLLink {

    @objc var frame = CGRect()
    
    open override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "x", let x = value as? Double {
            frame.origin.x = CGFloat(x)
        } else if key == "y", let y = value as? Double {
            frame.origin.y = CGFloat(y)
        } else if key == "w", let w = value as? Double {
            frame.size.width = CGFloat(w)
        } else if key == "h", let h = value as? Double {
            frame.size.height = CGFloat(h)
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
}
