//
//  AltitudeMode.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public enum AltitudeMode: String {
    case clampToGround = "clampToGround"
    case relativeToGround = "relativeToGround"
    case absolute = "absolute"
    case clampToSeaFloor = "clampToSeaFloor"
    case relativeToSeaFloor = "relativeToSeaFloor"
}

public enum SeaFloorAltitudeMode: String {
    case clampToSeaFloor = "clampToSeaFloor"
    case relativeToSeaFloor = "relativeToSeaFloor"
}
