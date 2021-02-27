//
//  StyleSelector.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import CoreGraphics

public class StyleSelector: KmlObject {
        
}

public class Style: StyleSelector {
    var iconStyle: IconStyle?
    var labelStyle: LabelStyle?
    var lineStyle: LineStyle?
    var polyStyle: PolyStyle?
    var balloonStyle: BalloonStyle?
    var listStyle: ListStyle?
}

public class SubStyle: Style {
    
}

public enum ColorMode: String {
    case normal = "normal"
    case random = "random"
}

public class ColorStyle: SubStyle {
    var color = KmlColor.white
    var colorMode = ColorMode.normal
}

public class BalloonStyle: ColorStyle {
    
    public enum DisplayMode: String {
        case `default` = "default"
        case hide = "hide"
    }
    
    public var bgColor: KmlColor?
    public var textColor: KmlColor?
    public var text = ""
    public var displayMode = DisplayMode.default
}

public class LabelStyle: ColorStyle {
    public var scale: Double = 1.0
}

public class LineStyle: ColorStyle {
    public var width: Double = 1.0
}

class ItemIcon: KmlObject {
    
    enum ItemIconState: String {
        case `open` = "open"
        case closed = "closed"
        case error = "error"
        case fetching0 = "fetching0"
        case fetching1 = "fetching1"
        case fetching2 = "fetching2"
    }
    
    var state: [ItemIconState] = []
    var href: URL?
}

class ListStyle: SubStyle {
    
    enum ListItemType: String {
        case radioFolder = "radioFolder"
        case check = "check"
        case checkHideChildren = "checkHideChildren"
        case checkOffOnly = "checkOffOnly"
    }
    
    var listItemType = ListItemType.check
    var bgColor = KmlColor.white
    var itemIcon: [ItemIcon] = []
    var maxSnippetLines = 2
}

class PolyStyle: ColorStyle {
    var fill = true
    var outline = true
}

class IconStyle: ColorStyle {
    var scale: Double = 1.0
    var heading: Double = 0.0
    var icon: Icon?
    var hotSpot = CGPoint()
}

class StyleMap: StyleSelector {
    
    class Pair {
        var key: String?
        var styleUrl: URL?
    }
    
    var pairs: [String:URL] = [:]
    
}


