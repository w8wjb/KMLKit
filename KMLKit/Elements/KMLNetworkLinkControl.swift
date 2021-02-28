//
//  NetworkLinkControl.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class KMLNetworkLinkControl: NSObject {
    @objc public var minRefreshPeriod: Float = 0
    @objc public var maxSessionLength: Float = -1
    @objc public var cookie: String?
    @objc public var message: String?
    @objc public var linkName: String?
    @objc public var linkDescription: String?
    @objc public var linkSnippet: String?
    @objc public var linkSnippetMaxLines: Int = -1
    @objc public var expires: Date?
    @objc public var update: KMLUpdate?
    @objc public var view: KMLAbstractView?
}
