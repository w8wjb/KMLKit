//
//  Feature.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

open class KMLFeature: KMLObject {
    @objc open var visibility = true
    @objc open var balloonVisibility = true
    @objc open var open = false
    @objc open var author: AtomAuthor?
    @objc open var link: AtomLink?
    @objc open var address: String?
    @objc open var addressDetails: [String:Any] = [:]
    @objc open var phoneNumber: String?
    @objc open var snippets: [KMLSnippet] = []
    @objc open var featureDescription: String?
    @objc open var view: KMLAbstractView?
    @objc open var styleUrl: URL?
    @objc open var styleSelector: [KMLStyleSelector] = []
    @objc open var region: KMLRegion?
    @objc open var extendedData: KMLExtendedData?

    open func findStyle(withId id: String) -> KMLStyle? {
        return styleSelector.compactMap({ $0 as? KMLStyle })
            .first(where: { $0.id == id })
    }

    open func findStyle(withUrl styleUrl: URL?) -> KMLStyle? {
        guard let styleUrl = styleUrl else { return nil }
        return styleSelector.compactMap({ $0 as? KMLStyle })
            .first(where: { $0.id == styleUrl.fragment })
    }

}
