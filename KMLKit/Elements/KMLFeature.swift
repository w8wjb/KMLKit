//
//  Feature.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class KMLFeature: KMLObject {
    @objc public var visibility = true
    @objc public var balloonVisibility = true
    @objc public var open = false
    @objc public var author: KMLAuthor?
    @objc public var link: KMLLink?
    @objc public var address: String?
    @objc public var addressDetails: KMLAddressDetails?
    @objc public var phoneNumber: String?
    @objc public var snippets: [KMLSnippet] = []
    @objc public var featureDescription: String?
    @objc public var view: KMLAbstractView?
    @objc public var styleUrl: URL?
    @objc public var styleSelector: [KMLStyleSelector] = []
    @objc public var region: KMLRegion?
    @objc public var extendedData: KMLExtendedData?

    public func findStyle(withId id: String) -> KMLStyle? {
        return styleSelector.compactMap({ $0 as? KMLStyle })
            .first(where: { $0.id == id })
    }

    public func findStyle(withUrl styleUrl: URL?) -> KMLStyle? {
        guard let styleUrl = styleUrl else { return nil }
        return styleSelector.compactMap({ $0 as? KMLStyle })
            .first(where: { $0.id == styleUrl.fragment })
    }

}
