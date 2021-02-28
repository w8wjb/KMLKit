//
//  AltitudeMode.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

@objc public enum KMLAltitudeMode: Int {
    case clampToGround
    case relativeToGround
    case absolute
    case clampToSeaFloor
    case relativeToSeaFloor
    
    init(_ value: String) {
        switch value {
        case "clampToGround":
            self = .clampToGround
        case "relativeToGround":
            self = .relativeToGround
        case "absolute":
            self = .absolute
        case "clampToSeaFloor":
            self = .clampToSeaFloor
        case "relativeToSeaFloor":
            self = .relativeToSeaFloor
        default:
            self = .clampToGround
        }
    }
    
}

@objc public enum KMLSeaFloorAltitudeMode: Int {
    case clampToSeaFloor
    case relativeToSeaFloor
    
    init(_ value: String) {
        switch value {
        case "clampToSeaFloor":
            self = .clampToSeaFloor
        case "relativeToSeaFloor":
            self = .relativeToSeaFloor
        default:
            self = .clampToSeaFloor
        }
    }
    
}
