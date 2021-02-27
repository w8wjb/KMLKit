//
//  Feature.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class KMLFeature: KMLObject {
    var visibility = true
    var balloonVisibility = true
    var open = false
    var author: KMLAuthor?
    var link: KMLLink?
    var address: String?
    var xalAddressDetails: KMLAddressDetails?
    var phoneNumber: String?
    var snippets: [KMLSnippet] = []
    var featureDescription: String?
    var abstractView: KMLAbstractView?
    var styleUrl: URL?
    var styleSelector: [KMLStyleSelector] = []
    var region: KMLRegion?

    func findStyle<T>(withId id: String) -> T? {
        return styleSelector.first(where: { $0.id == id }) as? T        
    }
    
}
