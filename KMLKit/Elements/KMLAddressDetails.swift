//
//  AddressDetails.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class KMLAddressDetails: NSObject {
    @objc public var address: String?
    @objc public var addressLines = [String]()
    @objc public var country: String?
    @objc public var administrativeArea: String?
    @objc public var locality: String?
    @objc public var thoroughfare: String?
    @objc public var currentStatus: String?
    @objc public var validFromDate: Date?
    @objc public var validToDate: Date?
    @objc public var usage: String?
    @objc public var addressDetailsKey: String?
    @objc public var code: String?
    @objc public var otherAttributes = [String:String]()
}
