//
//  Feature.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class Feature: KmlObject {
    var visibility = true
    var balloonVisibility = true
    var open = false
    var author: Author?
    var link: Link?
    var address: String?
    var xalAddressDetails: AddressDetails?
    var phoneNumber: String?
    var snippets: [Snippet] = []
    var description: String?
    var abstractView: AbstractView?
    var styleUrl: URL?
    var styleSelector: [StyleSelector] = []
    var region: Region?

    func findStyle<T>(withId id: String) -> T? {
        return styleSelector.first(where: { $0.id == id }) as? T        
    }
    
}
