//
//  AddressDetails.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

public class KMLAddressDetails {
    public var address: String?
    public var addressLines = [String]()
    public var country: String?
    public var administrativeArea: String?
    public var locality: String?
    public var thoroughfare: String?
    public var currentStatus: String?
    public var validFromDate: Date?
    public var validToDate: Date?
    public var usage: String?
    public var addressDetailsKey: String?
    public var code: String?
    public var otherAttributes = [String:String]()
}
