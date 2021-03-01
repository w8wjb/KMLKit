//
//  StyleSelector.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import CoreGraphics

public class KMLStyleSelector: KMLObject {
        
}

public class KMLStyle: KMLStyleSelector {
    @objc var iconStyle: KMLIconStyle?
    @objc var labelStyle: KMLLabelStyle?
    @objc var lineStyle: KMLLineStyle?
    @objc var polyStyle: KMLPolyStyle?
    @objc var balloonStyle: KMLBalloonStyle?
    @objc var listStyle: KMLListStyle?
}

public class KMLSubStyle: KMLStyle {
    
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

public class KMLColorStyle: KMLSubStyle {
    @objc var color = KMLColor.white
    @objc var colorMode = KMLColorMode.normal
    
    public override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "colorMode", let colorMode = value as? KMLColorMode {
            self.colorMode = colorMode
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
    
}

public class KMLBalloonStyle: KMLColorStyle {
    
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
    
    @objc public var bgColor: KMLColor?
    @objc public var textColor: KMLColor?
    @objc public var text = ""
    @objc public var displayMode = DisplayMode.default
}

public class KMLLabelStyle: KMLColorStyle {
    @objc public var scale: Double = 1.0
}

public class KMLLineStyle: KMLColorStyle {
    @objc public var width: Double = 1.0
}

class KMLItemIcon: KMLObject {
    
    @objc enum KMLItemIconState: Int {
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
    
    @objc var state: KMLItemIconState = .open
    @objc var href: URL?
}

class KMLListStyle: KMLSubStyle {
    
    @objc enum KMLListItemType: Int {
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
    
    @objc var listItemType = KMLListItemType.check
    @objc var bgColor = KMLColor.white
    @objc var itemIcon: [KMLItemIcon] = []
    @objc var maxSnippetLines = 2
    
    
    public override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "listItemType", let listItemType = value as? KMLListItemType {
            self.listItemType = listItemType
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
}

class KMLPolyStyle: KMLColorStyle {
    @objc var fill = true
    @objc var outline = true
}

class KMLIconStyle: KMLColorStyle {
    @objc var scale: Double = 1.0
    @objc var heading: Double = 0.0
    @objc var icon: KMLIcon?
    var hotSpot = CGPoint()
}

class KMLStyleMap: KMLStyleSelector {
    
    @objc var pairs: [String:URL] = [:]
    
}


