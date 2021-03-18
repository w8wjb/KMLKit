//
//  KMLTimeStamp.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/28/21.
//

import Foundation

/**
 This is an abstract element and cannot be used directly in a KML file. This element is extended by the &lt;TimeSpan&gt; and &lt;TimeStamp&gt; elements.
 */
@objc public protocol KMLTimePrimitive {
    func asDateComponents() -> DateComponents?
    func asDate() -> Date?
    func asInterval() -> DateInterval?
}

/**
 Represents a single moment in time.
 
 This is a simple element and contains no children. Its value is a dateTime, specified in XML time (see [XML Schema Part 2: Datatypes Second Edition](http://www.w3.org/TR/xmlschema-2/#isoformats)). The precision of the TimeStamp is dictated by the dateTime value in the &lt;when&gt; element.
 */
open class KMLTimeStamp: KMLObject, KMLTimePrimitive {

    internal static let gYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    internal static let gYearMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()
    
    internal static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    internal static let dateTimeFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()
    
    /**
     Specifies a single moment in time. The value is a dateTime, which can be one of the following:
     - *dateTime* gives second resolution
     - *date* gives day resolution
     - *gYearMonth* gives month resolution
     - *gYear* gives year resolution
     */
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

#if os(macOS)
extension KMLTimeStamp {

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)

        if let when = self.when, let date = Calendar.current.date(from: when) {
            var formatted: String? = nil
            if when.minute != nil {
                formatted = KMLTimeStamp.dateTimeFormatter.string(from: date)
            } else if when.day != nil {
                formatted = KMLTimeStamp.dateFormatter.string(from: date)
            } else if when.month != nil {
                formatted = KMLTimeStamp.gYearMonthFormatter.string(from: date)
            } else {
                formatted = KMLTimeStamp.gYearFormatter.string(from: date)
            }
            addSimpleChild(to: element, withName: "when", value: formatted)
        }
        
    }
}
#endif

/**
 Represents an extent in time bounded by begin and end dateTimes.

 If &lt;begin&gt; or &lt;end&gt; is missing, then that end of the period is unbounded (see Example below).

 The dateTime is defined according to XML Schema time (see [XML Schema Part 2: Datatypes Second Edition](http://www.w3.org/TR/xmlschema-2/#isoformats)). The value can be expressed as yyyy-mm-ddThh:mm:ss.ssszzzzzz, where T is the separator between the date and the time, and the time zone is either Z (for UTC) or zzzzzz, which represents ±hh:mm in relation to UTC. Additionally, the value can be expressed as a date only. See [&lt;TimeStamp&gt;](https://developers.google.com/kml/documentation/kmlreference#timestamp) for examples.
 */
open class KMLTimeSpan: KMLObject, KMLTimePrimitive {

    /** Describes the beginning instant of a time period. If absent, the beginning of the period is unbounded. */
    @objc open var begin: DateComponents?
    /** Describes the ending instant of a time period. If absent, the end of the period is unbounded. */
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

#if os(macOS)
extension KMLTimeSpan {

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)

        if let begin = self.begin, let date = Calendar.current.date(from: begin) {
            var formatted: String? = nil
            if begin.minute != nil {
                formatted = KMLTimeStamp.dateTimeFormatter.string(from: date)
            } else if begin.day != nil {
                formatted = KMLTimeStamp.dateFormatter.string(from: date)
            } else if begin.month != nil {
                formatted = KMLTimeStamp.gYearMonthFormatter.string(from: date)
            } else {
                formatted = KMLTimeStamp.gYearFormatter.string(from: date)
            }
            addSimpleChild(to: element, withName: "begin", value: formatted)
        }
        
        if let end = self.end, let date = Calendar.current.date(from: end) {
            var formatted: String? = nil
            if end.minute != nil {
                formatted = KMLTimeStamp.dateTimeFormatter.string(from: date)
            } else if end.day != nil {
                formatted = KMLTimeStamp.dateFormatter.string(from: date)
            } else if end.month != nil {
                formatted = KMLTimeStamp.gYearMonthFormatter.string(from: date)
            } else {
                formatted = KMLTimeStamp.gYearFormatter.string(from: date)
            }
            addSimpleChild(to: element, withName: "end", value: formatted)
        }
        
    }
}
#endif
