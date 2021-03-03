//
//  NetworkLinkControl.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

open class KMLNetworkLinkControl: NSObject {
    @objc open var minRefreshPeriod: Float = 0
    @objc open var maxSessionLength: Float = -1
    @objc open var cookie: String?
    @objc open var message: String?
    @objc open var linkName: String?
    @objc open var linkDescription: String?
    @objc open var linkSnippet: String?
    @objc open var linkSnippetMaxLines: Int = -1
    @objc open var expires: Date?
    @objc open var update: KMLUpdate?
    @objc open var view: KMLAbstractView?
}
