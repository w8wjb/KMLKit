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

public class KMLParser: NSObject, XMLParserDelegate {
    
    public static func parse(file: URL) throws -> KMLDocument {
        
        switch file.pathExtension {
        case "kmz":
            return try parseKMZ(file: file)
        case "kml":
            return try parseKML(file: file)
        default:
            throw ParsingError.unsupportedFormat(file.pathExtension)
        }
        
    }
    
    public static func parseKMZ(file: URL) throws -> KMLDocument {
        
        guard let kmz = Archive(url: file, accessMode: .read) else {
            throw ParsingError.failedToReadFile(file)
        }
        
        let kmlParser = KMLParser()
        
        var innerDoc: KMLDocument?
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
    
    public static func parseKML(file: URL) throws -> KMLDocument {
        let data = try Data(contentsOf: file)
        let kmlParser = KMLParser()
        return try kmlParser.parse(data: data)
    }
    
    public func parse(data: Data) throws -> KMLDocument {
        let xmlParser = XMLParser(data: data)
        xmlParser.delegate = self
        xmlParser.shouldProcessNamespaces = true
        xmlParser.parse()
        
        if let error = error {
            throw error
        }
        
        guard let root = self.root else {
            throw ParsingError.missingElement("kml")
        }
        
        return root
    }
    
    private var root: KMLDocument?
    var error: Error?
    
    private var buffer = ""
    private var stack: [Any] = []
    private var ignoreTags = false
    
    private func push(_ element: Any) {
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
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        buffer.append(string)
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attrs: [String : String] = [:]) {
        
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
        
        do {
            
            buffer = ""
            
            switch elementName {
            case "kml":
                push(KMLDocument())
            case "Alias":
                push(Model.Alias())
            case "AnimatedUpdate":
                push(AnimatedUpdate(attrs))
            case "author":
                push(Author())
            case "BalloonStyle":
                push(BalloonStyle(attrs))
            case "Camera":
                push(Camera(attrs))
            case "Change":
                push(Change())
            case "Document":
                push(Document(attrs))
            case "FlyTo":
                push(FlyTo(attrs))
            case "Folder":
                push(Folder(attrs))
            case "GroundOverlay":
                push(GroundOverlay(attrs))
            case "Icon":
                push(Icon())
            case "IconStyle":
                push(IconStyle(attrs))
            case "outerBoundaryIs":
                push(Boundary())
            case "innerBoundaryIs":
                push(Boundary())
            case "LabelStyle":
                push(LabelStyle(attrs))
            case "LineStyle":
                push(LineStyle(attrs))
            case "LookAt":
                push(LookAt(attrs))
            case "Pair":
                push(StyleMap.Pair())
            case "Polygon":
                push(Polygon(attrs))
            case "PolyStyle":
                push(PolyStyle(attrs))
            case "LatLonBox":
                push(LatLonBox())
            case "LinearRing":
                push(LinearRing(attrs))
            case "LineString":
                push(LineString(attrs))
            case "link":
                push(Link(attrs))
            case "MultiGeometry":
                push(MultiGeometry(attrs))
            case "overlayXY":
                push(parsePoint(attrs: attrs))
            case "Placemark":
                push(Placemark(attrs))
            case "Point":
                push(Point(attrs))
            case "Playlist":
                push(Playlist(attrs))
            case "Region":
                push(Region(attrs))
            case "rotationXY":
                push(parsePoint(attrs: attrs))
            case "screenXY":
                push(parsePoint(attrs: attrs))
            case "ScreenOverlay":
                push(ScreenOverlay(attrs))
            case "size":
                push(parseSize(attrs: attrs))
            case "Snippet":
                push(Snippet(attrs))
            case "Style":
                push(Style(attrs))
            case "StyleMap":
                push(StyleMap(attrs))
            case "Tour":
                push(Tour(attrs))
            case "Track":
                push(Track(attrs))
            case "Update":
                push(Update())
            case "Wait":
                push(Wait(attrs))

            case "description":
                ignoreTags = true

            // Ignore start of scalar values
            case "altitude",
                 "altitudeMode",
                 "balloonVisibility",
                 "bgColor",
                 "color",
                 "colorMode",
                 "coordinates",
                 "drawOrder",
                 "duration",
                 "east",
                 "extrude",
                 "flyToMode",
                 "heading",
                 "href",
                 "key",
                 "latitude",
                 "longitude",
                 "name",
                 "north",
                 "open",
                 "range",
                 "refreshInterval",
                 "refreshMode",
                 "roll",
                 "rotation",
                 "scale",
                 "south",
                 "styleUrl",
                 "targetHref",
                 "tessellate",
                 "text",
                 "tilt",
                 "viewBoundScale",
                 "visibility",
                 "west",
                 "width":
                break
                
            default:
                throw ParsingError.unsupportedElement(elementName: elementName)
            }
            
        } catch {
            self.error = error
            parser.abortParsing()
        }
        
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if ignoreTags {
            if elementName == "description" {
                ignoreTags = false
            } else {
                buffer.append("</\(elementName)>")
                return
            }
        }
        
        do {

            switch elementName {
            case "kml":
                root = pop() as? KMLDocument
                
            case "Alias":
                let child = try pop(Model.Alias.self, forElement: elementName)
                switch stack.last {
                case let model as Model:
                    model.resourceMap.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "AnimatedUpdate":
                let child = try pop(AnimatedUpdate.self, forElement: elementName)
                switch stack.last {
                case let playlist as Playlist:
                    playlist.items.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }

            case "author":
                let child = try pop(Author.self, forElement: elementName)
                switch stack.last {
                case let feature as Feature:
                    feature.author = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "BalloonStyle":
                let child = try pop(BalloonStyle.self, forElement: elementName)
                switch stack.last {
                case let style as Style:
                    style.balloonStyle = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Camera":
                let child = try pop(Camera.self, forElement: elementName)
                switch stack.last {
                case let flyto as FlyTo:
                    flyto.view = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Change":
                let child = try pop(Change.self, forElement: elementName)
                switch stack.last {
                case let update as Update:
                    update.items.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
                
            case "Document":
                let child = try pop(Document.self, forElement: elementName)
                switch stack.last {
                case let kml as KMLDocument:
                    kml.feature = child
                case let container as Container:
                    container.features.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "FlyTo":
                let child = try pop(FlyTo.self, forElement: elementName)
                switch stack.last {
                case let playlist as Playlist:
                    playlist.items.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }

            case "Folder":
                let child = try pop(Folder.self, forElement: elementName)
                switch stack.last {
                case let kml as KMLDocument:
                    kml.feature = child
                case let container as Container:
                    container.features.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "GroundOverlay":
                let child = try pop(GroundOverlay.self, forElement: elementName)
                switch stack.last {
                case let document as KMLDocument:
                    document.feature = child
                case let container as Container:
                    container.features.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Icon":
                let child = try pop(Icon.self, forElement: elementName)
                switch stack.last {
                case let overlay as Overlay:
                    overlay.icon = child
                case let style as IconStyle:
                    style.icon = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "IconStyle":
                let child = try pop(IconStyle.self, forElement: elementName)
                switch stack.last {
                case let style as Style:
                    style.iconStyle = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "LabelStyle":
                let child = try pop(LabelStyle.self, forElement: elementName)
                switch stack.last {
                case let style as Style:
                    style.labelStyle = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "LatLonBox":
                let child = try pop(LatLonBox.self, forElement: elementName)
                switch stack.last {
                case let overlay as GroundOverlay:
                    overlay.latLonBox = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "LinearRing":
                let child = try pop(LinearRing.self, forElement: elementName)
                switch stack.last {
                case let boundary as Boundary:
                    boundary.linearRing = child
                case let placemark as Placemark:
                    placemark.geometry = child
                case let multi as MultiGeometry:
                    multi.geometry.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "LineString":
                let child = try pop(LineString.self, forElement: elementName)
                switch stack.last {
                case let placemark as Placemark:
                    placemark.geometry = child
                case let multi as MultiGeometry:
                    multi.geometry.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "LineStyle":
                let child = try pop(LineStyle.self, forElement: elementName)
                switch stack.last {
                case let style as Style:
                    style.lineStyle = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "link":
                let child = try pop(Link.self, forElement: elementName)
                switch stack.last {
                case let feature as Feature:
                    feature.link = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Link":
                let child = try pop(Link.self, forElement: elementName)
                switch stack.last {
                case let feature as Feature:
                    feature.link = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }

                
            case "LookAt":
                let child = try pop(LookAt.self, forElement: elementName)
                switch stack.last {
                case let nlc as NetworkLinkControl:
                    nlc.view = child
                case let tour as Tour:
                    tour.abstractView = child
                case let feature as Feature:
                    feature.abstractView = child
                case let flyTo as FlyTo:
                    flyTo.view = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "MultiGeometry":
                let child = try pop(MultiGeometry.self, forElement: elementName)
                switch stack.last {
                case let placemark as Placemark:
                    placemark.geometry = child
                case let multi as MultiGeometry:
                    multi.geometry.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "outerBoundaryIs":
                let child = try pop(Boundary.self, forElement: elementName)
                switch stack.last {
                case let polygon as Polygon:
                    polygon.outerBoundaryIs = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }

            case "innerBoundaryIs":
                let child = try pop(Boundary.self, forElement: elementName)
                switch stack.last {
                case let polygon as Polygon:
                    polygon.innerBoundaryIs.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }

            case "Pair":
                let child = try pop(StyleMap.Pair.self, forElement: elementName)
                guard let key = child.key, let styleUrl = child.styleUrl else { return }
                switch stack.last {
                case let map as StyleMap:
                    map.pairs[key] = styleUrl
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Polygon":
                let child = try pop(Polygon.self, forElement: elementName)
                switch stack.last {
                case let placemark as Placemark:
                    placemark.geometry = child
                case let multi as MultiGeometry:
                    multi.geometry.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "PolyStyle":
                let child = try pop(PolyStyle.self, forElement: elementName)
                switch stack.last {
                case let style as Style:
                    style.polyStyle = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Placemark":
                let child = try pop(Placemark.self, forElement: elementName)
                switch stack.last {
                case let kml as KMLDocument:
                    kml.feature = child
                case let container as Container:
                    container.features.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Playlist":
                let child = try pop(Playlist.self, forElement: elementName)
                switch stack.last {
                case let tour as Tour:
                    tour.playlist = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }

            case "Point":
                let child = try pop(Point.self, forElement: elementName)
                switch stack.last {
                case let placemark as Placemark:
                    placemark.geometry = child
                case let multi as MultiGeometry:
                    multi.geometry.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Region":
                let child = try pop(Region.self, forElement: elementName)
                switch stack.last {
                case let feature as Feature:
                    feature.region = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Snippet":
                var child = try pop(Snippet.self, forElement: elementName)
                
                child.value = buffer
                
                switch stack.last {
                case let feature as Feature:
                    feature.snippets.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "ScreenOverlay":
                let child = try pop(ScreenOverlay.self, forElement: elementName)
                switch stack.last {
                case let kml as KMLDocument:
                    kml.feature = child
                case let container as Container:
                    container.features.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }

            case "Style":
                let child = try pop(Style.self, forElement: elementName)
                switch stack.last {
                case let feature as Feature:
                    feature.styleSelector.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "StyleMap":
                let child = try pop(StyleMap.self, forElement: elementName)
                switch stack.last {
                case let feature as Feature:
                    feature.styleSelector.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }

            case "Tour":
                let child = try pop(Tour.self, forElement: elementName)
                switch stack.last {
                case let container as Container:
                    container.features.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }

            case "Track":
                let child = try pop(Track.self, forElement: elementName)
                switch stack.last {
                case let placemark as Placemark:
                    placemark.geometry = child
                case let multi as MultiGeometry:
                    multi.geometry.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Update":
                let child = try pop(Update.self, forElement: elementName)
                switch stack.last {
                case let control as NetworkLinkControl:
                    control.update = child
                case let animated as AnimatedUpdate:
                    animated.update = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Wait":
                let child = try pop(Wait.self, forElement: elementName)
                switch stack.last {
                case let playlist as Playlist:
                    playlist.items.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            // MARK: - Scalar values below

            case "altitude":
                let value = CLLocationDistance(buffer) ?? 0.0
                switch stack.last {
                case let lookat as LookAt:
                    lookat.altitude = value
                case let camera as Camera:
                    camera.altitude = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "altitudeMode":
                let value = AltitudeMode(rawValue: buffer) ?? .clampToGround
                switch stack.last {
                case let geometry as Geometry:
                    geometry.altitudeMode = value
                case let lookAt as LookAt:
                    lookAt.altitudeMode = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "balloonVisibility":
                let value = (buffer as NSString).boolValue
                switch stack.last {
                case let feature as Feature:
                    feature.balloonVisibility = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }

            case "bgColor":
                let value = KmlColor(hex: buffer)
                switch stack.last {
                case let style as ListStyle:
                    style.bgColor = value
                case let style as BalloonStyle:
                    style.bgColor = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }

            case "color":
                let value = KmlColor(hex: buffer)
                switch stack.last {
                case let style as ColorStyle:
                    style.color = value
                case let overlay as Overlay:
                    overlay.color = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "colorMode":
                let value = ColorMode(rawValue: buffer) ?? .normal
                switch stack.last {
                case let style as ColorStyle:
                    style.colorMode = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
                
            case "coordinates":
                let value = parseCoordinates(buffer)
                switch stack.last {
                case let lineString as LineString:
                    lineString.coordinates = value
                case let point as Point:
                    if let coordinate = value.first {
                        point.location = coordinate
                    }
                case let linearRing as LinearRing:
                    linearRing.coordinates = value
                    
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "description":
                let value = buffer.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                switch stack.last {
                case let feature as Feature:
                    feature.description = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "drawOrder":
                let value = Int(buffer) ?? 0
                switch stack.last {
                case let overlay as Overlay:
                    overlay.drawOrder = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "duration":
                let value = Double(buffer) ?? 0
                switch stack.last {
                case let animatedUpdate as AnimatedUpdate:
                    animatedUpdate.duration = value
                case let flyTo as FlyTo:
                    flyTo.duration = value
                case let wait as Wait:
                    wait.duration = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }

            case "east":
                let value = CLLocationDegrees(buffer) ?? 0
                switch stack.last {
                case let box as AbstractLatLonBox:
                    box.east = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "extrude":
                let value = (buffer as NSString).boolValue
                switch stack.last {
                case let point as Point:
                    point.extrude = value
                case let track as Track:
                    track.extrude = value
                case let lineString as LineString:
                    lineString.extrude = value
                case let polygon as Polygon:
                    polygon.extrude = value
                case let linearRing as LinearRing:
                    linearRing.extrude = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "flyToMode":
                let value = FlyTo.FlyToMode(rawValue: buffer) ?? .bounce
                switch stack.last {
                case let flyto as FlyTo:
                    flyto.mode = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "heading":
                let value = CLLocationDirection(buffer) ?? 0
                switch stack.last {
                case let orientation as Orientation:
                    orientation.heading = value
                case let iconStyle as IconStyle:
                    iconStyle.heading = value
                case let lookat as LookAt:
                    lookat.heading = value
                case let camera as Camera:
                    camera.heading = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "key":
                let value = buffer
                switch stack.last {
                case let pair as StyleMap.Pair:
                    pair.key = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "href":
                guard let value = URL(string: buffer) else { break }
                switch stack.last {
                case let link as BasicLink:
                    link.href = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "latitude":
                guard let value = CLLocationDegrees(buffer) else { break }
                switch stack.last {
                case let lookat as LookAt:
                    lookat.latitude = value
                case let camera as Camera:
                    camera.latitude = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "longitude":
                guard let value = CLLocationDegrees(buffer) else { break }
                switch stack.last {
                case let lookat as LookAt:
                    lookat.longitude = value
                case let camera as Camera:
                    camera.longitude = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "name":
                let value = buffer
                switch stack.last {
                case let kml as KMLDocument:
                    kml.name = value
                case let obj as KmlObject:
                    obj.name = value
                case let author as Author:
                    author.nameOrUriOrEmail = [value]
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "north":
                let value = CLLocationDegrees(buffer) ?? 0
                switch stack.last {
                case let box as AbstractLatLonBox:
                    box.north = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "open":
                let value = (buffer as NSString).boolValue
                switch stack.last {
                case let feature as Feature:
                    feature.open = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "overlayXY":
                let value = try pop(CGPoint.self, forElement: elementName)
                switch stack.last {
                case let overlay as ScreenOverlay:
                    overlay.overlayXY = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "rotation":
                let value = Double(buffer) ?? 0
                switch stack.last {
                case let box as LatLonBox:
                    box.rotation = value
                case let overlay as ScreenOverlay:
                    overlay.rotation = value
                case let overlay as PhotoOverlay:
                    overlay.rotation = value                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }

            case "range":
                let value = Double(buffer) ?? 0
                switch stack.last {
                case let lookat as LookAt:
                    lookat.range = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "scale":
                let value = Double(buffer) ?? 1.0
                switch stack.last {
                case let style as LabelStyle:
                    style.scale = value
                case let style as IconStyle:
                    style.scale = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "size":
                let value = try pop(CGSize.self, forElement: elementName)
                switch stack.last {
                case let overlay as ScreenOverlay:
                    overlay.size = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "refreshInterval":
                let value = Double(buffer) ?? 4.0
                switch stack.last {
                case let link as Link:
                    link.refreshInterval = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "refreshMode":
                let value = Icon.RefreshMode(rawValue: buffer) ?? .onChange
                switch stack.last {
                case let link as Link:
                    link.refreshMode = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "roll":
                let value = Double(buffer) ?? 0
                switch stack.last {
                case let camera as Camera:
                    camera.roll = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "rotationXY":
                let value = try pop(CGPoint.self, forElement: elementName)
                switch stack.last {
                case let overlay as ScreenOverlay:
                    overlay.rotationXY = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }

            case "screenXY":
                let value = try pop(CGPoint.self, forElement: elementName)
                switch stack.last {
                case let overlay as ScreenOverlay:
                    overlay.screenXY = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "south":
                let value = CLLocationDegrees(buffer) ?? 0
                switch stack.last {
                case let box as AbstractLatLonBox:
                    box.south = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "sourceHref":
                guard let value = URL(string: buffer) else { break }
                switch stack.last {
                case let alias as Model.Alias:
                    alias.sourceHref = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "styleUrl":
                guard let value = URL(string: buffer) else { break }
                switch stack.last {
                case let feature as Feature:
                    feature.styleUrl = value
                case let pair as StyleMap.Pair:
                    pair.styleUrl = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "targetHref":
                guard let value = URL(string: buffer) else { break }
                switch stack.last {
                case let update as Update:
                    update.targetHref = value
                case let alias as Model.Alias:
                    alias.targetHref = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "tessellate":
                let value = (buffer as NSString).boolValue
                switch stack.last {
                case let lineString as LineString:
                    lineString.tessellate = value
                case let polygon as Polygon:
                    polygon.tessellate = value
                case let linearRing as LinearRing:
                    linearRing.tessellate = value
                case let track as Track:
                    track.tessellate = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "text":
                let value = buffer
                switch stack.last {
                case let style as BalloonStyle:
                    style.text = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "tilt":
                let value = Double(buffer) ?? 0
                switch stack.last {
                case let lookat as LookAt:
                    lookat.tilt = value
                case let camera as Camera:
                    camera.tilt = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "viewBoundScale":
                let value = Double(buffer) ?? 1.0
                switch stack.last {
                case let link as Link:
                    link.viewBoundScale = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "visibility":
                let value = (buffer as NSString).boolValue
                switch stack.last {
                case let feature as Feature:
                    feature.visibility = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "west":
                let value = CLLocationDegrees(buffer) ?? 0
                switch stack.last {
                case let box as AbstractLatLonBox:
                    box.west = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "width":
                let value = Double(buffer) ?? 1.0
                switch stack.last {
                case let style as LineStyle:
                    style.width = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            default:
                throw ParsingError.unsupportedElement(elementName: elementName)
            }
            
            buffer = ""
            
        } catch ParsingError.unsupportedRelationship(let parent, let child, let elementName, let line) {
            
            if let change = parent as? Change,
               let child = child as? KmlObject {
                change.objects.append(child)
                
            } else {
                self.error = ParsingError.unsupportedRelationship(parent: parent, child: child, elementName: elementName, line: line)
                parser.abortParsing()
            }
            
        } catch {
            
            self.error = error
            parser.abortParsing()
        }
        
    }
    
    func parseCoordinates(_ input: String) -> [CLLocation] {
        
        var coordinates: [CLLocation] = []
        let tuples = input.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            .components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for tupleString in tuples {
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
                                      horizontalAccuracy: kCLLocationAccuracyBest,
                                      verticalAccuracy: kCLLocationAccuracyBest,
                                      timestamp: Date())
            coordinates.append(location)
        }
        
        return coordinates
    }
    
    func parsePoint(attrs: [String:String]) -> CGPoint {
        let x = Double(attrs["x"] ?? "1.0") ?? 1.0
        let y = Double(attrs["y"] ?? "1.0") ?? 1.0
        return CGPoint(x: x, y: y)
    }
    
    func parseSize(attrs: [String:String]) -> CGSize {
        let width = Double(attrs["x"] ?? "1.0") ?? 1.0
        let height = Double(attrs["y"] ?? "1.0") ?? 1.0
        return CGSize(width: width, height: height)
    }

}
