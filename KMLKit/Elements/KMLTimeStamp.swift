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

open class KMLTimeStamp: KMLObject, KMLTimePrimitive {

    @objc open var when: DateComponents?
    
    open func asDateComponents() -> DateComponents? {
        return when
    }

    open func asDate() -> Date? {
        guard let components = when else { return nil }
        return Calendar.current.date(from: components)
    }
    
    open func asInterval() -> DateInterval? {
        guard let date = asDate() else { return nil }
        return DateInterval(start: date, end: date)
    }
}


open class KMLTimeSpan: KMLObject, KMLTimePrimitive {

    @objc open var begin: DateComponents?
    @objc open var end: DateComponents?
    
    open func asDateComponents() -> DateComponents? {
        return begin
    }
    
    open func asInterval() -> DateInterval? {
        guard let start = begin?.date, let end = self.end?.date else { return nil}        
        return DateInterval(start: start, end: end)
    }
    
    open func asDate() -> Date? {
        guard let components = begin else { return nil }
        return Calendar.current.date(from: components)
    }
    
}
