//
//  KMLParser.swift
//  QTH
//
//  Created by Weston Bustraan on 2/25/21.
//  Copyright © 2021 Weston Bustraan. All rights reserved.
//

import Foundation
import ZIPFoundation
import CoreLocation
import CoreGraphics

open class KMLParser: NSObject, XMLParserDelegate {
    
    private class KeyValuePair: NSObject {
        var key: String?
        var values: [Any] = []
        
        override init() {
            super.init()
        }
        
        init(key: String?) {
            super.init()
            self.key = key
        }
        
        override func setValue(_ value: Any?, forKey key: String) {
            if key == "key" {
                self.key = value as? String
            } else if let value = value {
                self.values.append(value)
            } else {
                super.setValue(value, forKey: key)
            }
        }
    }
    
    public static func parse(file: URL) throws -> KMLRoot {
        
        switch file.pathExtension {
        case "kmz":
            return try parseKMZ(file: file)
        case "kml":
            return try parseKML(file: file)
        default:
            throw ParsingError.unsupportedFormat(file.pathExtension)
        }
        
    }
    
    public static func parseKMZ(file: URL) throws -> KMLRoot {
        
        guard let kmz = Archive(url: file, accessMode: .read) else {
            throw ParsingError.failedToReadFile(file)
        }
        
        let kmlParser = KMLParser()
        
        var innerDoc: KMLRoot?
        for entry in kmz {
            if entry.path.hasSuffix(".kml") {
                let _ = try kmz.extract(entry, consumer: { (data) in
                    innerDoc = try kmlParser.parse(data: data)
                })
                break
            }
        }
        
        guard let doc = innerDoc else {
            throw ParsingError.failedToReadFile(file)
        }
        
        return doc
    }
    
    public static func parseKML(file: URL) throws -> KMLRoot {
        let data = try Data(contentsOf: file)
        let kmlParser = KMLParser()
        return try kmlParser.parse(data: data)
    }
    
    open func parse(file: URL) throws -> KMLRoot {
        let data = try Data(contentsOf: file)
        return try parse(data: data)
    }
    
    open func parse(data: Data) throws -> KMLRoot {
        let xmlParser = XMLParser(data: data)
        xmlParser.delegate = self
        xmlParser.shouldProcessNamespaces = true
        xmlParser.parse()

        if strict {
            if let error = errors.first {
                throw error
            }
        }
        
        guard let root = self.root else {
            throw ParsingError.missingElement("kml", line: xmlParser.lineNumber)
        }
        
        return root
    }
    
    private let kmlNamespace = "http://www.opengis.net/kml/2.2"
    private let xalNamespace = "urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"
    private let supportedNamespaces = ["http://earth.google.com/kml/2.0",
                               "http://earth.google.com/kml/2.1",
                               "http://earth.google.com/kml/2.2",
                               "http://www.opengis.net/kml/2.2",
                               "http://www.google.com/kml/ext/2.2",
                               "http://www.w3.org/2005/Atom",
                               "urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"]
    

    public var strict = true
    public var errors: [Error] = []

    private var root: KMLRoot?
    
    private var buffer = ""
    private var stack: [NSObject] = []
    private var ignoreTags = false
    private var whenIndex = -1
    private var coordIndex = -1
    
    private let gYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    private let gYearMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private let dateTimeFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()
    
    private func push(_ element: NSObject) {
        self.stack.append(element)
    }
    
    @discardableResult
    private func pop() -> Any? {
        return self.stack.popLast()
    }
    
    private func pop<T>(_ type: T.Type, forElement elementName: String) throws -> T {
        if let obj = pop() as? T {
            return obj
        }
        throw ParsingError.unexpectedElement(expected: elementName)
    }
    
    open func parser(_ parser: XMLParser, foundCharacters string: String) {
        buffer.append(string)
    }
    
    open func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attrs: [String : String] = [:]) {

        
        guard !ignoreTags else {
            buffer.append("<\(elementName)")
            if !attrs.isEmpty {
                buffer.append(" ")
                let attrString = attrs.map({ "\($0)=\"\($1)\""}).joined(separator: " ")
                buffer.append(attrString)
            }
            buffer.append(">")
            return
        }
        
        let ns = namespaceURI ?? kmlNamespace
        guard ns.isEmpty || supportedNamespaces.contains(ns) else {
            return
        }
        
        do {

            buffer = ""
            
            if xalNamespace == namespaceURI {
                let dict = NSMutableDictionary(dictionary: attrs)
                push(dict)
                return
            }
            
            switch elementName {
            case "kml":
                push(KMLRoot())
            case "Alias":
                push(NSMutableDictionary())
            case "AnimatedUpdate":
                push(KMLTourAnimatedUpdate(attrs))
            case "author":
                push(AtomAuthor())
            case "BalloonStyle":
                push(KMLBalloonStyle(attrs))
            case "Camera":
                push(KMLCamera(attrs))
            case "Change":
                push(KMLChange())
            case "Create":
                push(KMLCreate())
            case "Data":
                push(KMLData())
            case "Delete":
                push(KMLDelete())
            case "Document":
                push(KMLDocument(attrs))
            case "ExtendedData":
                push(KMLExtendedData())
            case "FlyTo":
                push(KMLTourFlyTo(attrs))
            case "Folder":
                push(KMLFolder(attrs))
            case "GroundOverlay":
                push(KMLGroundOverlay(attrs))
            case "hotSpot":
                push(parsePoint(attrs: attrs) as NSObject)
            case "Icon":
                push(KMLIcon())
            case "IconStyle":
                push(KMLIconStyle(attrs))
            case "ImagePyramid":
                push(KMLPhotoOverlay.ImagePyramid())
            case "ItemIcon":
                push(KMLItemIcon(attrs))
            case "outerBoundaryIs":
                push(KMLBoundary())
            case "innerBoundaryIs":
                push(KMLBoundary())
            case "LabelStyle":
                push(KMLLabelStyle(attrs))
            case "LineStyle":
                push(KMLLineStyle(attrs))
            case "LookAt":
                push(KMLLookAt(attrs))
            case "Metadata":
                push(NSMutableDictionary(dictionary:attrs))
            case "Orientation":
                push(KMLOrientation(attrs))
            case "Pair":
                push(KeyValuePair())
            case "Polygon":
                push(KMLPolygon(attrs))
            case "PolyStyle":
                push(KMLPolyStyle(attrs))
            case "LatLonAltBox":
                push(KMLLatLonAltBox(attrs))
            case "LatLonBox":
                push(KMLLatLonBox(attrs))
            case "LatLonQuad":
                push(KMLLatLonQuad(attrs))
            case "LinearRing":
                push(KMLLinearRing(attrs))
            case "LineString":
                push(KMLLineString(attrs))
            case "link":
                guard let href = attrs["href"], let url = URL(string: href) else { throw ParsingError.missingAttribute("href") }
                push(AtomLink(href: url, attrs))
            case "Link":
                push(KMLLink(attrs))
            case "ListStyle":
                push(KMLListStyle(attrs))
            case "Location":
                push(NSMutableDictionary())
            case "Lod":
                push(KMLLevelOfDetail(attrs))
            case "Model":
                push(KMLModel(attrs))
            case "MultiGeometry":
                push(KMLMultiGeometry(attrs))
            case "MultiTrack":
                push(KMLMultiTrack(attrs))
            case "NetworkLink":
                push(KMLNetworkLink(attrs))
            case "NetworkLinkControl":
                push(KMLNetworkLinkControl())
            case "option":
                push(KMLAbstractView.ViewOption(attrs))
            case "overlayXY":
                push(parsePoint(attrs: attrs) as NSObject)
            case "PhotoOverlay":
                push(KMLPhotoOverlay(attrs))
            case "Placemark":
                push(KMLPlacemark(attrs))
            case "Point":
                push(KMLPoint(attrs))
            case "Playlist":
                push(KMLPlaylist(attrs))
            case "Region":
                push(KMLRegion(attrs))
            case "ResourceMap":
                push(NSMutableDictionary())
            case "rotationXY":
                push(parsePoint(attrs: attrs) as NSObject)
            case "screenXY":
                push(parsePoint(attrs: attrs) as NSObject)
            case "Scale":
                push(KMLModel.KMLScale(attrs))
            case "Schema":
                push(KMLSchema(attrs))
            case "SchemaData":
                push(KMLSchemaData(attrs))
            case "ScreenOverlay":
                push(KMLScreenOverlay(attrs))
            case "SimpleArrayData":
                push(KeyValuePair(key: attrs["name"]))
            case "SimpleArrayField":
                push(KMLSimpleArrayField(attrs))
            case "SimpleData":
                push(KeyValuePair(key: attrs["name"]))
            case "SimpleField":
                push(KMLSimpleField(attrs))
            case "size":
                push(parseSize(attrs: attrs) as NSObject)
            case "Snippet":
                push(KMLSnippet(attrs))
            case "SoundCue":
                push(KMLTourSoundCue(attrs))
            case "Style":
                push(KMLStyle(attrs))
            case "StyleMap":
                push(KMLStyleMap(attrs))
            case "TimeSpan":
                push(KMLTimeSpan(attrs))
            case "TimeStamp":
                push(KMLTimeStamp(attrs))
            case "Tour":
                push(KMLTour(attrs))
            case "TourControl":
                push(KMLTourControl(attrs))
            case "Track":
                push(KMLTrack(attrs))
                whenIndex = -1
                coordIndex = -1
            case "Update":
                push(KMLUpdate())
            case "ViewerOptions":
                push(NSMutableArray())
            case "ViewVolume":
                push(KMLPhotoOverlay.ViewVolume())
            case "Wait":
                push(KMLTourWait(attrs))

            case "description":
                ignoreTags = true

            // MARK: - Ignore start of scalar values
            case "address",
                 "altitude",
                 "altitudeMode",
                 "altitudeOffset",
                 "angles",
                 "balloonVisibility",
                 "begin",
                 "bgColor",
                 "bottomFov",
                 "color",
                 "colorMode",
                 "cookie",
                 "coord",
                 "coordinates",
                 "delayedStart",
                 "displayMode",
                 "displayName",
                 "drawOrder",
                 "duration",
                 "east",
                 "email",
                 "end",
                 "extrude",
                 "fill",
                 "flyToMode",
                 "gridOrigin",
                 "heading",
                 "horizFov",
                 "href",
                 "httpQuery",
                 "interpolate",
                 "key",
                 "latitude",
                 "leftFov",
                 "linkDescription",
                 "linkName",
                 "linkSnippet",
                 "listItemType",
                 "longitude",
                 "maxAltitude",
                 "maxFadeExtent",
                 "maxHeight",
                 "maxLodPixels",
                 "maxSessionLength",
                 "maxSnippetLines",
                 "maxWidth",
                 "message",
                 "minAltitude",
                 "minFadeExtent",
                 "minLodPixels",
                 "minRefreshPeriod",
                 "name",
                 "near",
                 "north",
                 "open",
                 "outline",
                 "phoneNumber",
                 "playMode",
                 "range",
                 "refreshInterval",
                 "refreshMode",
                 "rightFov",
                 "roll",
                 "rotation",
                 "scale",
                 "seaFloorAltitudeMode",
                 "shape",
                 "sourceHref",
                 "south",
                 "state",
                 "styleUrl",
                 "targetHref",
                 "tessellate",
                 "text",
                 "textColor",
                 "tileSize",
                 "tilt",
                 "topFov",
                 "uri",
                 "value",
                 "viewBoundScale",
                 "viewFormat",
                 "viewRefreshTime",
                 "visibility",
                 "west",
                 "when",
                 "width",
                 "w", "h", "x", "y", "z":
                break
                
            default:
                throw ParsingError.unsupportedElement(elementName: elementName, line: parser.lineNumber)
            }
            
        } catch {
            self.errors.append(error)
            if strict {
                parser.abortParsing()
            }
        }
        
    }
    
    open func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        

        if ignoreTags {
            if elementName == "description" {
                ignoreTags = false
            } else {
                buffer.append("</\(elementName)>")
                return
            }
        }
        
        let ns = namespaceURI ?? kmlNamespace
        guard ns.isEmpty || supportedNamespaces.contains(ns) else {
            return
        }

        do {
            
            if xalNamespace == namespaceURI {
                let dict = try pop(NSMutableDictionary.self, forElement: elementName)
                buffer = buffer.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                if !buffer.isEmpty {
                    dict.setValue(buffer, forKey: "value")
                    buffer = ""
                }
                switch stack.last {
                case let feature as KMLFeature:
                    feature.addressDetails = dict as! [String : Any]
                case let parentDict as NSMutableDictionary:
                    parentDict.setValue(dict, forKey: elementName)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: dict, elementName: elementName, line: parser.lineNumber)
                }
                return
            }
            
            switch elementName {
            case "kml":
                root = pop() as? KMLRoot
                
            case "Alias":
                let dict = try pop(NSDictionary.self, forElement: elementName)
                
                guard let targetHref = dict.value(forKey: "targetHref") as? URL else { return }
                guard let sourceHref = dict.value(forKey: "sourceHref") as? URL else { return }

                guard let resourceMap = stack.last as? NSMutableDictionary else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: dict, elementName: elementName, line: parser.lineNumber)
                }
                resourceMap.setValue(targetHref.description, forKey: sourceHref.description)
                
            case "AnimatedUpdate":
                let child = try pop(KMLTourAnimatedUpdate.self, forElement: elementName)
                stack.last?.mutableArrayValue(forKey: "items").add(child)

            case "author":
                let child = try pop(AtomAuthor.self, forElement: elementName)
                stack.last?.setValue(child, forKey: elementName)
                
            case "BalloonStyle":
                let child = try pop(KMLBalloonStyle.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "balloonStyle")
                
            case "Camera":
                let child = try pop(KMLCamera.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "view")
                
            case "Change":
                let child = try pop(KMLChange.self, forElement: elementName)
                stack.last?.mutableArrayValue(forKey: "items").add(child)
                
            case "Create":
                let child = try pop(KMLCreate.self, forElement: elementName)
                stack.last?.mutableArrayValue(forKey: "items").add(child)

            case "Data":
                let child = try pop(KMLData.self, forElement: elementName)
                stack.last?.mutableArrayValue(forKey: "data").add(child)
                
            case "Delete":
                let child = try pop(KMLDelete.self, forElement: elementName)
                stack.last?.mutableArrayValue(forKey: "items").add(child)
                
            case "Document":
                let child = try pop(KMLDocument.self, forElement: elementName)
                guard let collection = stack.last as? KMLFeatureCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                collection.add(feature: child)
                
            case "ExtendedData":
                let child = try pop(KMLExtendedData.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "extendedData")
                
            case "FlyTo":
                let child = try pop(KMLTourFlyTo.self, forElement: elementName)
                stack.last?.mutableArrayValue(forKey: "items").add(child)

            case "Folder":
                let child = try pop(KMLFolder.self, forElement: elementName)
                guard let collection = stack.last as? KMLFeatureCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                collection.add(feature: child)

            case "GroundOverlay":
                let child = try pop(KMLGroundOverlay.self, forElement: elementName)
                guard let collection = stack.last as? KMLFeatureCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                collection.add(feature: child)

            case "hotSpot":
                let child = try pop(CGPoint.self, forElement: elementName)
                stack.last?.setValue(child, forKey: elementName)
                
            case "Icon":
                let child = try pop(KMLIcon.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "icon")
                
            case "IconStyle":
                let child = try pop(KMLIconStyle.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "iconStyle")
                
            case "ImagePyramid":
                let child = try pop(KMLPhotoOverlay.ImagePyramid.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "imagePyramid")
                
            case "ItemIcon":
                let child = try pop(KMLItemIcon.self, forElement: elementName)
                stack.last?.mutableArrayValue(forKey: "itemIcon").add(child)

            case "LabelStyle":
                let child = try pop(KMLLabelStyle.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "labelStyle")
                
            case "LatLonAltBox":
                let child = try pop(KMLLatLonAltBox.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "extent")

            case "LatLonBox":
                let child = try pop(KMLLatLonBox.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "extent")
                
            case "LatLonQuad":
                let child = try pop(KMLLatLonQuad.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "extent")
                
            case "LinearRing":
                let child = try pop(KMLLinearRing.self, forElement: elementName)
                if let collection = stack.last as? KMLGeometryCollection {
                    collection.add(geometry: child)
                } else {
                    stack.last?.setValue(child, forKey: "linearRing")
                }
                
            case "LineString":
                let child = try pop(KMLLineString.self, forElement: elementName)
                guard let collection = stack.last as? KMLGeometryCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                collection.add(geometry: child)

            case "LineStyle":
                let child = try pop(KMLLineStyle.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "lineStyle")
                
            case "link":
                let child = try pop(AtomLink.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "link")

            case "Link":
                let child = try pop(KMLLink.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "link")
                
            case "ListStyle":
                let child = try pop(KMLListStyle.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "listStyle")

            case "Location":
                let child = try pop(NSDictionary.self, forElement: elementName)
                
                let longitude = child.value(forKey: "longitude") as? CLLocationDegrees ?? 0.0
                let latitude = child.value(forKey: "latitude") as? CLLocationDegrees ?? 0.0
                let altitude = child.value(forKey: "altitude") as? CLLocationDistance ?? 0.0
                
                let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                           altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: -1, timestamp: Date())
                stack.last?.setValue(location, forKey: "location")

            case "Lod":
                let child = try pop(KMLLevelOfDetail.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "lod")

            case "LookAt":
                let child = try pop(KMLLookAt.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "view")
            case "Metadata":
                let dict = try pop(NSMutableDictionary.self, forElement: elementName) as! [String:Any]
                guard let feature = stack.last as? KMLFeature else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: dict, elementName: elementName, line: parser.lineNumber)
                }
                
                let dataValues = dict.map { (key: String, value: Any) -> KMLData in
                    let data = KMLData()
                    data.displayName = key
                    data.value = value
                    return data
                }
                feature.extendedData?.data.append(contentsOf: dataValues)

                
            case "Model":
                let child = try pop(KMLModel.self, forElement: elementName)
                switch stack.last {
                case let track as KMLTrack:
                    track.model = child
                case let collection as KMLGeometryCollection:
                    collection.add(geometry: child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                
            case "MultiGeometry":
                let child = try pop(KMLMultiGeometry.self, forElement: elementName)
                guard let collection = stack.last as? KMLGeometryCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                collection.add(geometry: child)
                
            case "MultiTrack":
                let child = try pop(KMLMultiTrack.self, forElement: elementName)
                guard let collection = stack.last as? KMLGeometryCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                collection.add(geometry: child)

            case "NetworkLink":
                let child = try pop(KMLNetworkLink.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "link")
                
            case "NetworkLinkControl":
                let child = try pop(KMLNetworkLinkControl.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "networkLinkControl")
                
            case "option":
                let child = try pop(KMLAbstractView.ViewOption.self, forElement: elementName)
                guard let options = stack.last as? NSMutableArray else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                options.add(child)
                
            case "Orientation":
                let child = try pop(KMLOrientation.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "orientation")

            case "outerBoundaryIs":
                let child = try pop(KMLBoundary.self, forElement: elementName)
                stack.last?.setValue(child, forKey: elementName)

            case "innerBoundaryIs":
                let child = try pop(KMLBoundary.self, forElement: elementName)
                stack.last?.mutableArrayValue(forKey: elementName).add(child)

            case "Pair":
                let child = try pop(KeyValuePair.self, forElement: elementName)
                guard let key = child.key else { return }
                guard let map = stack.last as? KMLStyleMap else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                
                switch child.values.first {
                case let style as KMLStyleSelector:
                    map.pairs[key] = style
                case let url as URL:
                    map.pairs[key] = KMLStyleRef(styleUrl: url)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                
            case "Polygon":
                let child = try pop(KMLPolygon.self, forElement: elementName)
                guard let collection = stack.last as? KMLGeometryCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                collection.add(geometry: child)

            case "PolyStyle":
                let child = try pop(KMLPolyStyle.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "polyStyle")
                
            case "PhotoOverlay":
                let child = try pop(KMLPhotoOverlay.self, forElement: elementName)
                guard let collection = stack.last as? KMLFeatureCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                collection.add(feature: child)
                
            case "Placemark":
                let child = try pop(KMLPlacemark.self, forElement: elementName)
                guard let collection = stack.last as? KMLFeatureCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                collection.add(feature: child)

            case "Playlist":
                let child = try pop(KMLPlaylist.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "playlist")

            case "Point":
                let child = try pop(KMLPoint.self, forElement: elementName)
                switch stack.last {
                case let overlay as KMLPhotoOverlay:
                    overlay.point = child
                case let collection as KMLGeometryCollection:
                    collection.add(geometry: child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                
            case "Region":
                let child = try pop(KMLRegion.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "region")
                
            case "ResourceMap":
                let child = try pop(NSMutableDictionary.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "resourceMap")
                
            case "Scale":
                let child = try pop(KMLModel.KMLScale.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "scale")
                
            case "Snippet":
                let child = try pop(KMLSnippet.self, forElement: elementName)
                child.value = buffer.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                stack.last?.mutableArrayValue(forKey: "snippets").add(child)
                
            case "Schema":
                let child = try pop(KMLSchema.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "schema")
                
            case "SchemaData":
                let child = try pop(KMLSchemaData.self, forElement: elementName)
                stack.last?.mutableArrayValue(forKey: "schemaData").add(child)

            case "ScreenOverlay":
                let child = try pop(KMLScreenOverlay.self, forElement: elementName)
                guard let collection = stack.last as? KMLFeatureCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                collection.add(feature: child)
                
            case "SimpleArrayData":
                let child = try pop(KeyValuePair.self, forElement: elementName)
                guard let key = child.key else {
                    throw ParsingError.missingElement("key", line: parser.lineNumber)
                }
                guard let schemaData = stack.last as? KMLSchemaData else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                schemaData.data[key] = child.values

            case "SimpleArrayField":
                let child = try pop(KMLSimpleArrayField.self, forElement: elementName)
                stack.last?.mutableArrayValue(forKey: "fields").add(child)
            
            case "SimpleData":
                let child = try pop(KeyValuePair.self, forElement: elementName)
                guard let key = child.key else {
                    throw ParsingError.missingElement("key", line: parser.lineNumber)
                }
                
                let value = child.values.first as? String ?? buffer.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                guard let schemaData = stack.last as? KMLSchemaData else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                schemaData.data[key] = value
                
            case "SimpleField":
                let child = try pop(KMLSimpleField.self, forElement: elementName)
                stack.last?.mutableArrayValue(forKey: "fields").add(child)
                
            case "SoundCue":
                let child = try pop(KMLTourSoundCue.self, forElement: elementName)
                stack.last?.mutableArrayValue(forKey: "items").add(child)
                
            case "Style":
                let child = try pop(KMLStyle.self, forElement: elementName)
                switch stack.last {
                case let pair as KeyValuePair:
                    pair.values.append(child)
                case let feature as KMLFeature:
                    feature.styleSelector.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                
                
            case "StyleMap":
                let child = try pop(KMLStyleMap.self, forElement: elementName)
                guard let feature = stack.last as? KMLFeature else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                feature.styleSelector.append(child)
                
            case "TimeSpan":
                let child = try pop(KMLTimeSpan.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "time")

            case "TimeStamp":
                let child = try pop(KMLTimeStamp.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "time")

            case "Tour":
                let child = try pop(KMLTour.self, forElement: elementName)
                guard let collection = stack.last as? KMLFeatureCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }
                collection.add(feature: child)
                
            case "TourControl":
                let child = try pop(KMLTourControl.self, forElement: elementName)
                stack.last?.mutableArrayValue(forKey: "items").add(child)

            case "Track":
                let child = try pop(KMLTrack.self, forElement: elementName)
                switch stack.last {
                case let multiTrack as KMLMultiTrack:
                    multiTrack.tracks.append(child)
                case let collection as KMLGeometryCollection:
                    collection.add(geometry: child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName, line: parser.lineNumber)
                }

            case "Update":
                let child = try pop(KMLUpdate.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "update")
                
            case "ViewerOptions":
                let child = try pop(NSArray.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "options")
                
            case "ViewVolume":
                let child = try pop(KMLPhotoOverlay.ViewVolume.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "viewVolume")

            case "Wait":
                let child = try pop(KMLTourWait.self, forElement: elementName)
                stack.last?.mutableArrayValue(forKey: "items").add(child)
                
            // MARK: - Scalar values below

            case "altitude":
                let value = CLLocationDistance(buffer) ?? 0.0
                stack.last?.setValue(value, forKey: elementName)
                
            case "altitudeMode":
                let value = KMLAltitudeMode(buffer)
                stack.last?.setValue(value, forKey: elementName)
                
            case "angles":
                let value = buffer.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                stack.last?.mutableArrayValue(forKey: elementName).add(value)
                
            case "begin":
                let value = try parseDateTimeAsComponents(buffer)
                stack.last?.setValue(value, forKey: elementName)

            case "bgColor":
                let value = KMLColor(hex: buffer)
                stack.last?.setValue(value, forKey: elementName)
                
            case "color":
                let value = KMLColor(hex: buffer)
                stack.last?.setValue(value, forKey: elementName)
                
            case "colorMode":
                let value = KMLColorMode(buffer)
                stack.last?.setValue(value, forKey: elementName)
                
            case "coord":
                guard let value = parseCoordinates(buffer).first else {
                    throw ParsingError.missingElement("coord", line: parser.lineNumber)
                }
                guard let track = stack.last as? KMLTrack else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName, line: parser.lineNumber)
                }
                coordIndex += 1
                if coordIndex < track.coordinates.endIndex {
                    let existingLocation = track.coordinates[coordIndex]
                    let updatedLocation = CLLocation(coordinate: value.coordinate,
                                                     altitude: value.altitude,
                                                     horizontalAccuracy: 0,
                                                     verticalAccuracy: -1,
                                                     timestamp: existingLocation.timestamp)
                    track.coordinates[coordIndex] = updatedLocation

                } else {
                    let newLocation = value
                    track.coordinates.append(newLocation)
                }
                
            case "coordinates":
                let value = parseCoordinates(buffer)
                stack.last?.setValue(value, forKey: elementName)
            
            case "description":
                let value = buffer.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                stack.last?.setValue(value, forKey: "featureDescription")

            case "displayMode":
                let value = KMLBalloonStyle.DisplayMode(buffer)
                stack.last?.setValue(value, forKey: elementName)
                
            case "east":
                let value = CLLocationDegrees(buffer) ?? 0
                stack.last?.setValue(value, forKey: elementName)
                
            case "end":
                let value = try parseDateTimeAsComponents(buffer)
                stack.last?.setValue(value, forKey: elementName)

            case "flyToMode":
                let value = KMLTourFlyTo.FlyToMode(buffer)
                stack.last?.setValue(value, forKey: elementName)
                
            case "gridOrigin":
                let value = KMLPhotoOverlay.GridOrigin(buffer)
                stack.last?.setValue(value, forKey: elementName)
                
            case "heading":
                let value = CLLocationDirection(buffer) ?? 0
                stack.last?.setValue(value, forKey: elementName)
                
            case "href", "uri":
                guard let value = URL(string: buffer) else { break }
                stack.last?.setValue(value, forKey: elementName)
                
            case "latitude":
                guard let value = CLLocationDegrees(buffer) else { break }
                stack.last?.setValue(value, forKey: elementName)
                
            case "longitude":
                guard let value = CLLocationDegrees(buffer) else { break }
                stack.last?.setValue(value, forKey: elementName)
                
            case "listItemType":
                let value = KMLListStyle.ListItemType(buffer)
                stack.last?.setValue(value, forKey: elementName)
                
            case "maxSnippetLines":
                let value = Int(buffer) ?? 2
                stack.last?.setValue(value, forKey: elementName)
                
            case "north":
                let value = CLLocationDegrees(buffer) ?? 0
                stack.last?.setValue(value, forKey: elementName)
                
            case "overlayXY":
                let value = try pop(CGPoint.self, forElement: elementName)
                stack.last?.setValue(value, forKey: elementName)

            case "playMode":
                let value = KMLTourControl.PlayMode(buffer)
                stack.last?.setValue(value, forKey: elementName)

            case "refreshInterval":
                let value = Double(buffer) ?? 4.0
                stack.last?.setValue(value, forKey: elementName)

            case "refreshMode":
                let value = KMLIcon.KMLRefreshMode(buffer)
                stack.last?.setValue(value, forKey: elementName)

            case "rotationXY":
                let value = try pop(CGPoint.self, forElement: elementName)
                stack.last?.setValue(value, forKey: elementName)

            case "scale":
                let value = Double(buffer) ?? 1.0
                stack.last?.setValue(value, forKey: elementName)

            case "screenXY":
                let value = try pop(CGPoint.self, forElement: elementName)
                stack.last?.setValue(value, forKey: elementName)

            case "seaFloorAltitudeMode":
                let value = KMLSeaFloorAltitudeMode(buffer)
                stack.last?.setValue(value, forKey: elementName)

            case "shape":
                let value = KMLPhotoOverlay.Shape(buffer)
                stack.last?.setValue(value, forKey: elementName)
                
            case "size":
                let value = try pop(CGSize.self, forElement: elementName)
                stack.last?.setValue(value, forKey: elementName)

            case "south":
                let value = CLLocationDegrees(buffer) ?? 0
                stack.last?.setValue(value, forKey: elementName)

            case "sourceHref":
                guard let value = URL(string: buffer) else { break }
                stack.last?.setValue(value, forKey: elementName)

            case "state":
                let value = KMLItemIcon.IconState(buffer)
                stack.last?.setValue(value, forKey: elementName)

            case "styleUrl":
                guard let value = URL(string: buffer) else { break }
                stack.last?.setValue(value, forKey: elementName)

            case "targetHref":
                guard let value = URL(string: buffer) else { break }
                stack.last?.setValue(value, forKey: elementName)

            case "textColor":
                let value = KMLColor(hex: buffer)
                stack.last?.setValue(value, forKey: elementName)

            case "tileSize":
                let value = Int(buffer) ?? 256
                stack.last?.setValue(value, forKey: elementName)
                
            case "viewBoundScale":
                let value = Double(buffer) ?? 1.0
                stack.last?.setValue(value, forKey: elementName)

            case "viewRefreshTime":
                let value = Double(buffer) ?? 1.0
                stack.last?.setValue(value, forKey: elementName)

            case "west":
                let value = CLLocationDegrees(buffer) ?? 0
                stack.last?.setValue(value, forKey: elementName)
                
            case "when":
                switch stack.last {
                case let track as KMLTrack:
                    let value = try parseDateTime(buffer)
                    whenIndex += 1
                    if whenIndex < track.coordinates.endIndex {
                        let existingLocation = track.coordinates[whenIndex]
                        let updatedLocation = CLLocation(coordinate: existingLocation.coordinate,
                                                         altitude: existingLocation.altitude,
                                                         horizontalAccuracy: 0,
                                                         verticalAccuracy: -1,
                                                         timestamp: value)
                        track.coordinates[whenIndex] = updatedLocation
                        
                    } else {
                        let newLocation = CLLocation(coordinate: CLLocationCoordinate2D(),
                                                     altitude: CLLocationDistance(),
                                                     horizontalAccuracy: 0,
                                                     verticalAccuracy: -1,
                                                     timestamp: value)
                        track.coordinates.append(newLocation)
                    }
                    
                default:
                    let value = try parseDateTimeAsComponents(buffer)
                    stack.last?.setValue(value, forKey: elementName)
                }
                
            case "width":
                let value = Double(buffer) ?? 1.0
                stack.last?.setValue(value, forKey: elementName)
                
            case "w", "h", "x", "y", "z":
                let value = Double(buffer) ?? 1.0
                stack.last?.setValue(value, forKey: elementName)

            // MARK: - Int scalars, default 0
            case "drawOrder", "maxHeight", "maxSessionLength", "maxWidth":
                let value = Int(buffer) ?? 0
                stack.last?.setValue(value, forKey: elementName)
                
            // MARK: - Double scalars, default 0
            case "altitudeOffset", "bottomFov", "delayedStart", "duration", "horizFov", "leftFov", "minAltitude",
                 "maxAltitude", "maxFadeExtent", "maxLodPixels", "minFadeExtent", "minLodPixels", "minRefreshPeriod",
                 "near", "range", "rightFov", "roll", "rotation", "tilt", "topFov" :
                let value = Double(buffer) ?? 0.0
                stack.last?.setValue(value, forKey: elementName)

            // MARK: - Boolean scalars
            case "balloonVisibility", "extrude", "fill", "interpolate", "open", "outline", "tessellate", "visibility":
                let value = (buffer as NSString).boolValue
                stack.last?.setValue(value, forKey: elementName)
            
            // MARK: - String scalars
            case "address",
                 "cookie",
                 "displayName",
                 "email",
                 "httpQuery",
                 "key",
                 "linkName",
                 "linkDescription",
                 "linkSnippet",
                 "message",
                 "name",
                 "phoneNumber",
                 "text",
                 "value",
                 "viewFormat":
                let value = buffer.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                stack.last?.setValue(value, forKey: elementName)

                
            default:
                throw ParsingError.unsupportedElement(elementName: elementName, line: parser.lineNumber)
            }
            
            buffer = ""
            
        } catch ParsingError.unsupportedRelationship(let parent, let child, let elementName, let line) {
            
            if let change = parent as? KMLChange,
               let child = child as? KMLObject {
                change.objects.append(child)

            } else if let delete = parent as? KMLDelete,
                      let child = child as? KMLFeature {
                delete.features.append(child)

            } else if let delete = parent as? KMLDelete,
                      let child = child as? KMLGeometry {
                delete.geometry.append(child)

            } else if let create = parent as? KMLCreate,
                      let child = child as? KMLContainer {
                create.containers.append(child)

            } else if let create = parent as? KMLCreate,
                      let child = child as? KMLMultiTrack {
                create.multiTracks.append(child)

            } else if let create = parent as? KMLCreate,
                      let child = child as? KMLMultiGeometry {
                create.multiGeometry.append(child)

            } else {
                self.errors.append(ParsingError.unsupportedRelationship(parent: parent, child: child, elementName: elementName, line: line))
                if strict {
                    parser.abortParsing()
                }
            }
            
        } catch {
            self.errors.append(error)
            if strict {
                parser.abortParsing()
            }
        }
        
    }

    func parseDateTime(_ input: String) throws -> Date {
                
        if let date = gYearFormatter.date(from: input) {
            return date
        } else if let date = gYearMonthFormatter.date(from: input) {
            return date
        } else if let date = dateFormatter.date(from: input) {
            return date
        } else if let date = dateTimeFormatter.date(from: input) {
            return date
        }
        throw ParsingError.unsupportedDateFormat(input)
    }
    
    func parseDateTimeAsComponents(_ input: String) throws -> DateComponents {
                
        if let date = gYearFormatter.date(from: input) {
            return Calendar.current.dateComponents([.year], from: date)
        } else if let date = gYearMonthFormatter.date(from: input) {
            return Calendar.current.dateComponents([.year, .month], from: date)
        } else if let date = dateFormatter.date(from: input) {
            return Calendar.current.dateComponents([.year, .month, .day], from: date)
        } else if let date = dateTimeFormatter.date(from: input) {
            return Calendar.current.dateComponents(in: TimeZone.current, from: date)
        }
        throw ParsingError.unsupportedDateFormat(input)
    }
    
    func parseCoordinates(_ input: String) -> [CLLocation] {
        
        var coordinates: [CLLocation] = []
        let tuples = input.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            .components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for tupleString in tuples {
            if tupleString.isEmpty {
                continue
            }
            
            let tuple = tupleString.components(separatedBy: ",")
                        
            var longitude = CLLocationDegrees()
            var latitude = CLLocationDegrees()
            var altitude = CLLocationDistance()
            
            for (i, part) in tuple.enumerated() {
                switch i {
                case 0:
                    longitude = CLLocationDegrees(part) ?? 0
                case 1:
                    latitude = CLLocationDegrees(part) ?? 0
                case 2:
                    altitude = CLLocationDistance(part) ?? 0
                default:
                    break
                }
            }

            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let location = CLLocation(coordinate:coordinate,
                                      altitude: altitude,
                                      horizontalAccuracy: 0,
                                      verticalAccuracy: -1,
                                      timestamp: Date())
            coordinates.append(location)
        }
        
        return coordinates
    }
    
    func parsePoint(attrs: [String:String]) -> NSPoint {
        let x = Double(attrs["x"] ?? "1.0") ?? 1.0
        let y = Double(attrs["y"] ?? "1.0") ?? 1.0
        return NSPoint(x: x, y: y)
    }
    
    func parseSize(attrs: [String:String]) -> NSSize {
        let width = Double(attrs["x"] ?? "1.0") ?? 1.0
        let height = Double(attrs["y"] ?? "1.0") ?? 1.0
        return CGSize(width: width, height: height)
    }

}
