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
    
    public func parse(data: Data) throws -> KMLRoot {
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
    
    private var root: KMLRoot?
    var error: Error?
    
    private var buffer = ""
    private var stack: [NSObject] = []
    private var ignoreTags = false
    
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
                push(KMLRoot())
            case "Alias":
                push(KMLModel.KMLAlias())
            case "AnimatedUpdate":
                push(AnimatedUpdate(attrs))
            case "author":
                push(KMLAuthor())
            case "BalloonStyle":
                push(KMLBalloonStyle(attrs))
            case "Camera":
                push(KMLCamera(attrs))
            case "Change":
                push(KMLChange())
            case "Document":
                push(KMLDocument(attrs))
            case "FlyTo":
                push(FlyTo(attrs))
            case "Folder":
                push(KMLFolder(attrs))
            case "GroundOverlay":
                push(KMLGroundOverlay(attrs))
            case "Icon":
                push(KMLIcon())
            case "IconStyle":
                push(KMLIconStyle(attrs))
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
            case "Pair":
                push(KMLStyleMap.Pair())
            case "Polygon":
                push(KMLPolygon(attrs))
            case "PolyStyle":
                push(KMLPolyStyle(attrs))
            case "LatLonBox":
                push(KMLLatLonBox())
            case "LinearRing":
                push(KMLLinearRing(attrs))
            case "LineString":
                push(KMLLineString(attrs))
            case "link":
                push(KMLLink(attrs))
            case "MultiGeometry":
                push(KMLMultiGeometry(attrs))
            case "overlayXY":
                push(parsePoint(attrs: attrs) as NSObject)
            case "Placemark":
                push(KMLPlacemark(attrs))
            case "Point":
                push(KMLPoint(attrs))
            case "Playlist":
                push(KMLPlaylist(attrs))
            case "Region":
                push(KMLRegion(attrs))
            case "rotationXY":
                push(parsePoint(attrs: attrs) as NSObject)
            case "screenXY":
                push(parsePoint(attrs: attrs) as NSObject)
            case "ScreenOverlay":
                push(ScreenOverlay(attrs))
            case "size":
                push(parseSize(attrs: attrs) as NSObject)
            case "Snippet":
                push(KMLSnippet(attrs))
            case "Style":
                push(KMLStyle(attrs))
            case "StyleMap":
                push(KMLStyleMap(attrs))
            case "Tour":
                push(KMLTour(attrs))
            case "Track":
                push(KMLTrack(attrs))
            case "Update":
                push(KMLUpdate())
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
                root = pop() as? KMLRoot
                
            case "Alias":
                let child = try pop(KMLModel.KMLAlias.self, forElement: elementName)
                stack.last?.mutableArrayValue(forKey: "resourceMap").add(child)
                
            case "AnimatedUpdate":
                let child = try pop(AnimatedUpdate.self, forElement: elementName)
                stack.last?.mutableArrayValue(forKey: "items").add(child)

            case "author":
                let child = try pop(KMLAuthor.self, forElement: elementName)
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
                
            case "Document":
                let child = try pop(KMLDocument.self, forElement: elementName)
                guard let collection = stack.last as? KMLFeatureCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                collection.add(feature: child)
                
            case "FlyTo":
                let child = try pop(FlyTo.self, forElement: elementName)
                stack.last?.mutableArrayValue(forKey: "items").add(child)

            case "Folder":
                let child = try pop(KMLFolder.self, forElement: elementName)
                guard let collection = stack.last as? KMLFeatureCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                collection.add(feature: child)

            case "GroundOverlay":
                let child = try pop(KMLGroundOverlay.self, forElement: elementName)
                guard let collection = stack.last as? KMLFeatureCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                collection.add(feature: child)

            case "Icon":
                let child = try pop(KMLIcon.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "icon")
                
            case "IconStyle":
                let child = try pop(KMLIconStyle.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "iconStyle")
                
            case "LabelStyle":
                let child = try pop(KMLLabelStyle.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "labelStyle")
                
            case "LatLonBox":
                let child = try pop(KMLLatLonBox.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "latLonBox")
                
            case "LinearRing":
                let child = try pop(KMLLinearRing.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "linearRing")
                
            case "LineString":
                let child = try pop(KMLLineString.self, forElement: elementName)
                guard let collection = stack.last as? KMLGeometryCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                collection.add(geometry: child)

            case "LineStyle":
                let child = try pop(KMLLineStyle.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "lineStyle")
                
            case "Link", "link":
                let child = try pop(KMLLink.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "link")
                
            case "LookAt":
                let child = try pop(KMLLookAt.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "view")
                
            case "MultiGeometry":
                let child = try pop(KMLMultiGeometry.self, forElement: elementName)
                guard let collection = stack.last as? KMLGeometryCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                collection.add(geometry: child)

            case "outerBoundaryIs":
                let child = try pop(KMLBoundary.self, forElement: elementName)
                stack.last?.setValue(child, forKey: elementName)

            case "innerBoundaryIs":
                let child = try pop(KMLBoundary.self, forElement: elementName)
                stack.last?.mutableArrayValue(forKey: elementName).add(child)

            case "Pair":
                let child = try pop(KMLStyleMap.Pair.self, forElement: elementName)
                guard let key = child.key,
                      let styleUrl = child.styleUrl,
                      let map = stack.last as? KMLStyleMap
                else { return }
                map.pairs[key] = styleUrl
                
            case "Polygon":
                let child = try pop(KMLPolygon.self, forElement: elementName)
                guard let collection = stack.last as? KMLGeometryCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                collection.add(geometry: child)

            case "PolyStyle":
                let child = try pop(KMLPolyStyle.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "polyStyle")
                
            case "Placemark":
                let child = try pop(KMLPlacemark.self, forElement: elementName)
                guard let collection = stack.last as? KMLFeatureCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                collection.add(feature: child)

            case "Playlist":
                let child = try pop(KMLPlaylist.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "playlist")

            case "Point":
                let child = try pop(KMLPoint.self, forElement: elementName)
                guard let collection = stack.last as? KMLGeometryCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                collection.add(geometry: child)
                
            case "Region":
                let child = try pop(KMLRegion.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "region")
                
            case "Snippet":
                let child = try pop(KMLSnippet.self, forElement: elementName)
                child.value = buffer
                stack.last?.mutableArrayValue(forKey: "snippets").add(child)
                
            case "ScreenOverlay":
                let child = try pop(ScreenOverlay.self, forElement: elementName)
                guard let collection = stack.last as? KMLFeatureCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                collection.add(feature: child)

            case "Style":
                let child = try pop(KMLStyle.self, forElement: elementName)
                guard let feature = stack.last as? KMLFeature else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                feature.styleSelector.append(child)
                
            case "StyleMap":
                let child = try pop(KMLStyleMap.self, forElement: elementName)
                guard let feature = stack.last as? KMLFeature else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                feature.styleSelector.append(child)

            case "Tour":
                let child = try pop(KMLTour.self, forElement: elementName)
                guard let collection = stack.last as? KMLFeatureCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                collection.add(feature: child)

            case "Track":
                let child = try pop(KMLTrack.self, forElement: elementName)
                guard let collection = stack.last as? KMLGeometryCollection else {
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                collection.add(geometry: child)

            case "Update":
                let child = try pop(KMLUpdate.self, forElement: elementName)
                stack.last?.setValue(child, forKey: "update")
                
            case "Wait":
                let child = try pop(Wait.self, forElement: elementName)
                stack.last?.mutableArrayValue(forKey: "items").add(child)
                
            // MARK: - Scalar values below

            case "altitude":
                let value = CLLocationDistance(buffer) ?? 0.0
                stack.last?.setValue(value, forKey: elementName)
                
            case "altitudeMode":
                let value = KMLAltitudeMode(buffer)
                stack.last?.setValue(value, forKey: elementName)
                
            case "balloonVisibility":
                let value = (buffer as NSString).boolValue
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
                
            case "coordinates":
                let value = parseCoordinates(buffer)
                stack.last?.setValue(value, forKey: elementName)
                
            case "description":
                let value = buffer.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                stack.last?.setValue(value, forKey: "featureDescription")
                
            case "drawOrder":
                let value = Int(buffer) ?? 0
                stack.last?.setValue(value, forKey: elementName)
                
            case "duration":
                let value = Double(buffer) ?? 0
                stack.last?.setValue(value, forKey: elementName)

            case "east":
                let value = CLLocationDegrees(buffer) ?? 0
                stack.last?.setValue(value, forKey: elementName)
                
            case "extrude":
                let value = (buffer as NSString).boolValue
                stack.last?.setValue(value, forKey: elementName)
                
            case "flyToMode":
                let value = FlyTo.FlyToMode(buffer)
                stack.last?.setValue(value, forKey: elementName)
                
            case "heading":
                let value = CLLocationDirection(buffer) ?? 0
                stack.last?.setValue(value, forKey: elementName)
                
            case "key":
                let value = buffer
                stack.last?.setValue(value, forKey: elementName)
                
            case "href":
                guard let value = URL(string: buffer) else { break }
                stack.last?.setValue(value, forKey: elementName)
                
            case "latitude":
                guard let value = CLLocationDegrees(buffer) else { break }
                stack.last?.setValue(value, forKey: elementName)
                
            case "longitude":
                guard let value = CLLocationDegrees(buffer) else { break }
                stack.last?.setValue(value, forKey: elementName)

            case "name":
                let value = buffer
                stack.last?.setValue(value, forKey: elementName)
                
            case "north":
                let value = CLLocationDegrees(buffer) ?? 0
                stack.last?.setValue(value, forKey: elementName)
                
            case "open":
                let value = (buffer as NSString).boolValue
                stack.last?.setValue(value, forKey: elementName)
                
            case "overlayXY":
                let value = try pop(CGPoint.self, forElement: elementName)
                stack.last?.setValue(value, forKey: elementName)

            case "rotation":
                let value = Double(buffer) ?? 0
                stack.last?.setValue(value, forKey: elementName)

            case "range":
                let value = Double(buffer) ?? 0
                stack.last?.setValue(value, forKey: elementName)

            case "scale":
                let value = Double(buffer) ?? 1.0
                stack.last?.setValue(value, forKey: elementName)

            case "size":
                let value = try pop(CGSize.self, forElement: elementName)
                stack.last?.setValue(value, forKey: elementName)

            case "refreshInterval":
                let value = Double(buffer) ?? 4.0
                stack.last?.setValue(value, forKey: elementName)

            case "refreshMode":
                let value = KMLIcon.KMLRefreshMode(buffer)
                stack.last?.setValue(value, forKey: elementName)

            case "roll":
                let value = Double(buffer) ?? 0
                stack.last?.setValue(value, forKey: elementName)

            case "rotationXY":
                let value = try pop(CGPoint.self, forElement: elementName)
                stack.last?.setValue(value, forKey: elementName)

            case "screenXY":
                let value = try pop(CGPoint.self, forElement: elementName)
                stack.last?.setValue(value, forKey: elementName)

            case "south":
                let value = CLLocationDegrees(buffer) ?? 0
                stack.last?.setValue(value, forKey: elementName)

            case "sourceHref":
                guard let value = URL(string: buffer) else { break }
                stack.last?.setValue(value, forKey: elementName)

            case "styleUrl":
                guard let value = URL(string: buffer) else { break }
                stack.last?.setValue(value, forKey: elementName)

            case "targetHref":
                guard let value = URL(string: buffer) else { break }
                stack.last?.setValue(value, forKey: elementName)

            case "tessellate":
                let value = (buffer as NSString).boolValue
                stack.last?.setValue(value, forKey: elementName)

            case "text":
                let value = buffer
                stack.last?.setValue(value, forKey: elementName)

            case "tilt":
                let value = Double(buffer) ?? 0
                stack.last?.setValue(value, forKey: elementName)

            case "viewBoundScale":
                let value = Double(buffer) ?? 1.0
                stack.last?.setValue(value, forKey: elementName)

            case "visibility":
                let value = (buffer as NSString).boolValue
                stack.last?.setValue(value, forKey: elementName)

            case "west":
                let value = CLLocationDegrees(buffer) ?? 0
                stack.last?.setValue(value, forKey: elementName)

            case "width":
                let value = Double(buffer) ?? 1.0
                stack.last?.setValue(value, forKey: elementName)

            default:
                throw ParsingError.unsupportedElement(elementName: elementName)
            }
            
            buffer = ""
            
        } catch ParsingError.unsupportedRelationship(let parent, let child, let elementName, let line) {
            
            if let change = parent as? KMLChange,
               let child = child as? KMLObject {
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
