//
//  StyleSelector.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import CoreGraphics

@objc public protocol KMLStyleSelector {
    
}

open class KMLStyle: KMLObject, KMLStyleSelector {
    @objc var iconStyle: KMLIconStyle?
    @objc var labelStyle: KMLLabelStyle?
    @objc var lineStyle: KMLLineStyle?
    @objc var polyStyle: KMLPolyStyle?
    @objc var balloonStyle: KMLBalloonStyle?
    @objc var listStyle: KMLListStyle?
}

open class KMLSubStyle: KMLStyle {
    
}

@objc public enum KMLColorMode: Int {
    case normal
    case random
    
    init(_ value: String) {
        switch value {
        case "normal":
            self = .normal
        case "random":
            self = .random
        default:
            self = .normal
        }
    }
}

open class KMLColorStyle: KMLSubStyle {
    @objc var color = KMLColor.white
    @objc var colorMode = KMLColorMode.normal
    
    open override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "colorMode", let colorMode = value as? KMLColorMode {
            self.colorMode = colorMode
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
    
}

open class KMLBalloonStyle: KMLColorStyle {
    
    @objc public enum DisplayMode: Int {
        case `default`
        case hide
        
        init(_ value: String) {
            switch value {
            case "default":
                self = .default
            case "hide":
                self = .hide
            default:
                self = .default
            }
        }
    }
    
    @objc open var bgColor: KMLColor?
    @objc open var textColor: KMLColor?
    @objc open var text = ""
    @objc open var displayMode = DisplayMode.default
    
    open override func setValue(_ value: Any?, forKey key: String) {
        if key == "displayMode", let displayMode = value as? DisplayMode {
            self.displayMode = displayMode
        } else {
            super.setValue(value, forKey: key)
        }
    }
}

open class KMLLabelStyle: KMLColorStyle {
    @objc open var scale: Double = 1.0
}

open class KMLLineStyle: KMLColorStyle {
    @objc open var width: Double = 1.0
}

open class KMLItemIcon: KMLObject {
    
    @objc(KMLItemIconState)
    enum IconState: Int {
        case `open`
        case closed
        case error
        case fetching0
        case fetching1
        case fetching2
        
        init(_ value: String) {
            switch value {
            case "open":
                self = .open
            case "closed":
                self = .closed
            case "error":
                self = .error
            case "fetching0":
                self = .fetching0
            case "fetching1":
                self = .fetching1
            case "fetching2":
                self = .fetching2
            default:
                self = .open
            }
        }
    }
    
    @objc var state: IconState = .open
    @objc var href: URL?
    
    open override func setValue(_ value: Any?, forKey key: String) {
        if key == "state", let state = value as? IconState {
            self.state = state
        } else {
            super.setValue(value, forKey: key)
        }
    }
}

open class KMLListStyle: KMLSubStyle {
    
    @objc(KMLListItemType) enum ListItemType: Int {
        case radioFolder
        case check
        case checkHideChildren
        case checkOffOnly
        
        init(_ value: String) {
            switch value {
            case "radioFolder":
                self = .radioFolder
            case "check":
                self = .check
            case "checkHideChildren":
                self = .checkHideChildren
            case "checkOffOnly":
                self = .checkOffOnly
            default:
                self = .check
            }
        }
    }
    
    @objc var listItemType = ListItemType.check
    @objc var bgColor = KMLColor.white
    @objc var itemIcon: [KMLItemIcon] = []
    @objc var maxSnippetLines = 2
    
    
    open override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "listItemType", let listItemType = value as? ListItemType {
            self.listItemType = listItemType
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
}

open class KMLPolyStyle: KMLColorStyle {
    @objc var fill = true
    @objc var outline = true
}

open class KMLIconStyle: KMLColorStyle {
    @objc var scale: Double = 1.0
    @objc var heading: Double = 0.0
    @objc var icon: KMLIcon?
    var hotSpot = CGPoint()
    
    open override func setValue(_ value: Any?, forKey key: String) {
        if key == "hotSpot", let hotSpot = value as? CGPoint {
            self.hotSpot = hotSpot
        } else {
            super.setValue(value, forKey: key)
        }
    }

    
}

open class KMLStyleRef: NSObject, KMLStyleSelector {
    @objc open var styleUrl: URL
    
    public init(styleUrl: URL) {
        self.styleUrl = styleUrl
        super.init()
    }
    
}

open class KMLStyleMap: KMLObject, KMLStyleSelector {
    @objc var pairs: [String:KMLStyleSelector] = [:]
}

extension KMLStyleMap: Sequence {

    public typealias Element = (key: String, value: KMLStyleSelector)
    public typealias Iterator = Dictionary<String, KMLStyleSelector>.Iterator
    
    public func makeIterator() -> Iterator {
        return pairs.makeIterator()
    }

}

// Pseudo-dictionary interface
extension KMLStyleMap {
    
    subscript(key: String) -> KMLStyleSelector? {
        return pairs[key]
    }
    
    public var keys: Dictionary<String, KMLStyleSelector>.Keys {
        return pairs.keys
    }
    
    public var values: Dictionary<String, KMLStyleSelector>.Values {
        return pairs.values
    }
}


