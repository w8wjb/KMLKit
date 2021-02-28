//
//  Feature.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class KMLFeature: KMLObject {
    @objc var visibility = true
    @objc var balloonVisibility = true
    @objc var open = false
    @objc var author: KMLAuthor?
    @objc var link: KMLLink?
    @objc var address: String?
    @objc var xalAddressDetails: KMLAddressDetails?
    @objc var phoneNumber: String?
    @objc var snippets: [KMLSnippet] = []
    @objc var featureDescription: String?
    @objc var view: KMLAbstractView?
    @objc var styleUrl: URL?
    @objc var styleSelector: [KMLStyleSelector] = []
    @objc var region: KMLRegion?

    func findStyle<T>(withId id: String) -> T? {
        return styleSelector.first(where: { $0.id == id }) as? T        
    }
    
}
