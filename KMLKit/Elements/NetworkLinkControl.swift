//
//  NetworkLinkControl.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class NetworkLinkControl {
    public var minRefreshPeriod: Float = 0
    public var maxSessionLength: Float = -1
    public var cookie: String?
    public var message: String?
    public var linkName: String?
    public var linkDescription: String?
    public var linkSnippet: String?
    public var linkSnippetMaxLines: Int = -1
    public var expires: Date?
    public var update: Update?
    public var view: AbstractView?
}
