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
    var iconStyle: KMLIconStyle?
    var labelStyle: KMLLabelStyle?
    var lineStyle: KMLLineStyle?
    var polyStyle: KMLPolyStyle?
    var balloonStyle: KMLBalloonStyle?
    var listStyle: KMLListStyle?
}

public class KMLSubStyle: KMLStyle {
    
}

public enum KMLColorMode: String {
    case normal = "normal"
    case random = "random"
}

public class KMLColorStyle: KMLSubStyle {
    var color = KMLColor.white
    var colorMode = KMLColorMode.normal
}

public class KMLBalloonStyle: KMLColorStyle {
    
    public enum DisplayMode: String {
        case `default` = "default"
        case hide = "hide"
    }
    
    public var bgColor: KMLColor?
    public var textColor: KMLColor?
    public var text = ""
    public var displayMode = DisplayMode.default
}

public class KMLLabelStyle: KMLColorStyle {
    public var scale: Double = 1.0
}

public class KMLLineStyle: KMLColorStyle {
    public var width: Double = 1.0
}

class KMLItemIcon: KMLObject {
    
    enum KMLItemIconState: String {
        case `open` = "open"
        case closed = "closed"
        case error = "error"
        case fetching0 = "fetching0"
        case fetching1 = "fetching1"
        case fetching2 = "fetching2"
    }
    
    var state: [KMLItemIconState] = []
    var href: URL?
}

class KMLListStyle: KMLSubStyle {
    
    enum ListItemType: String {
        case radioFolder = "radioFolder"
        case check = "check"
        case checkHideChildren = "checkHideChildren"
        case checkOffOnly = "checkOffOnly"
    }
    
    var listItemType = ListItemType.check
    var bgColor = KMLColor.white
    var itemIcon: [KMLItemIcon] = []
    var maxSnippetLines = 2
}

class KMLPolyStyle: KMLColorStyle {
    var fill = true
    var outline = true
}

class KMLIconStyle: KMLColorStyle {
    var scale: Double = 1.0
    var heading: Double = 0.0
    var icon: Icon?
    var hotSpot = CGPoint()
}

class KMLStyleMap: KMLStyleSelector {
    
    class Pair: NSObject {
        var key: String?
        var styleUrl: URL?
    }
    
    var pairs: [String:URL] = [:]
    
}


