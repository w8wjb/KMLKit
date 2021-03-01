//
//  KMLTimeStamp.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/28/21.
//

import Foundation

@objc public protocol KMLTimePrimitive {
    func asDateComponents() -> DateComponents?
    func asDate() -> Date?
    func asInterval() -> DateInterval?
}

public class KMLTimeStamp: KMLObject, KMLTimePrimitive {

    @objc public var when: DateComponents?
    
    public func asDateComponents() -> DateComponents? {
        return when
    }

    public func asDate() -> Date? {
        guard let components = when else { return nil }
        return Calendar.current.date(from: components)
    }
    
    public func asInterval() -> DateInterval? {
        guard let date = asDate() else { return nil }
        return DateInterval(start: date, end: date)
    }
}


public class KMLTimeSpan: KMLObject, KMLTimePrimitive {

    @objc public var begin: DateComponents?
    @objc public var end: DateComponents?
    
    public func asDateComponents() -> DateComponents? {
        return begin
    }
    
    public func asInterval() -> DateInterval? {
        guard let start = begin?.date, let end = self.end?.date else { return nil}        
        return DateInterval(start: start, end: end)
    }
    
    public func asDate() -> Date? {
        guard let components = begin else { return nil }
        return Calendar.current.date(from: components)
    }
    
}
