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
                push(Icon())
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
                switch stack.last {
                case let model as KMLModel:
                    model.resourceMap.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "AnimatedUpdate":
                let child = try pop(AnimatedUpdate.self, forElement: elementName)
                switch stack.last {
                case let playlist as KMLPlaylist:
                    playlist.items.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }

            case "author":
                let child = try pop(KMLAuthor.self, forElement: elementName)
                switch stack.last {
                case let feature as KMLFeature:
                    feature.author = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "BalloonStyle":
                let child = try pop(KMLBalloonStyle.self, forElement: elementName)
                switch stack.last {
                case let style as KMLStyle:
                    style.balloonStyle = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Camera":
                let child = try pop(KMLCamera.self, forElement: elementName)
                switch stack.last {
                case let flyto as FlyTo:
                    flyto.view = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Change":
                let child = try pop(KMLChange.self, forElement: elementName)
                switch stack.last {
                case let update as KMLUpdate:
                    update.items.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
                
            case "Document":
                let child = try pop(KMLDocument.self, forElement: elementName)
                switch stack.last {
                case let kml as KMLRoot:
                    kml.feature = child
                case let container as KMLContainer:
                    container.features.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "FlyTo":
                let child = try pop(FlyTo.self, forElement: elementName)
                switch stack.last {
                case let playlist as KMLPlaylist:
                    playlist.items.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }

            case "Folder":
                let child = try pop(KMLFolder.self, forElement: elementName)
                switch stack.last {
                case let kml as KMLRoot:
                    kml.feature = child
                case let container as KMLContainer:
                    container.features.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "GroundOverlay":
                let child = try pop(KMLGroundOverlay.self, forElement: elementName)
                switch stack.last {
                case let kml as KMLRoot:
                    kml.feature = child
                case let container as KMLContainer:
                    container.features.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Icon":
                let child = try pop(Icon.self, forElement: elementName)
                switch stack.last {
                case let overlay as KMLOverlay:
                    overlay.icon = child
                case let style as KMLIconStyle:
                    style.icon = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "IconStyle":
                let child = try pop(KMLIconStyle.self, forElement: elementName)
                switch stack.last {
                case let style as KMLStyle:
                    style.iconStyle = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "LabelStyle":
                let child = try pop(KMLLabelStyle.self, forElement: elementName)
                switch stack.last {
                case let style as KMLStyle:
                    style.labelStyle = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "LatLonBox":
                let child = try pop(KMLLatLonBox.self, forElement: elementName)
                switch stack.last {
                case let overlay as KMLGroundOverlay:
                    overlay.latLonBox = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "LinearRing":
                let child = try pop(KMLLinearRing.self, forElement: elementName)
                switch stack.last {
                case let boundary as KMLBoundary:
                    boundary.linearRing = child
                case let placemark as KMLPlacemark:
                    placemark.geometry = child
                case let multi as KMLMultiGeometry:
                    multi.geometry.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "LineString":
                let child = try pop(KMLLineString.self, forElement: elementName)
                switch stack.last {
                case let placemark as KMLPlacemark:
                    placemark.geometry = child
                case let multi as KMLMultiGeometry:
                    multi.geometry.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "LineStyle":
                let child = try pop(KMLLineStyle.self, forElement: elementName)
                switch stack.last {
                case let style as KMLStyle:
                    style.lineStyle = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "link":
                let child = try pop(KMLLink.self, forElement: elementName)
                switch stack.last {
                case let feature as KMLFeature:
                    feature.link = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Link":
                let child = try pop(KMLLink.self, forElement: elementName)
                switch stack.last {
                case let feature as KMLFeature:
                    feature.link = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }

                
            case "LookAt":
                let child = try pop(KMLLookAt.self, forElement: elementName)
                switch stack.last {
                case let nlc as KMLNetworkLinkControl:
                    nlc.view = child
                case let tour as KMLTour:
                    tour.abstractView = child
                case let feature as KMLFeature:
                    feature.abstractView = child
                case let flyTo as FlyTo:
                    flyTo.view = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "MultiGeometry":
                let child = try pop(KMLMultiGeometry.self, forElement: elementName)
                switch stack.last {
                case let placemark as KMLPlacemark:
                    placemark.geometry = child
                case let multi as KMLMultiGeometry:
                    multi.geometry.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "outerBoundaryIs":
                let child = try pop(KMLBoundary.self, forElement: elementName)
                switch stack.last {
                case let polygon as KMLPolygon:
                    polygon.outerBoundaryIs = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }

            case "innerBoundaryIs":
                let child = try pop(KMLBoundary.self, forElement: elementName)
                switch stack.last {
                case let polygon as KMLPolygon:
                    polygon.innerBoundaryIs.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }

            case "Pair":
                let child = try pop(KMLStyleMap.Pair.self, forElement: elementName)
                guard let key = child.key, let styleUrl = child.styleUrl else { return }
                switch stack.last {
                case let map as KMLStyleMap:
                    map.pairs[key] = styleUrl
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Polygon":
                let child = try pop(KMLPolygon.self, forElement: elementName)
                switch stack.last {
                case let placemark as KMLPlacemark:
                    placemark.geometry = child
                case let multi as KMLMultiGeometry:
                    multi.geometry.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "PolyStyle":
                let child = try pop(KMLPolyStyle.self, forElement: elementName)
                switch stack.last {
                case let style as KMLStyle:
                    style.polyStyle = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Placemark":
                let child = try pop(KMLPlacemark.self, forElement: elementName)
                switch stack.last {
                case let kml as KMLRoot:
                    kml.feature = child
                case let container as KMLContainer:
                    container.features.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Playlist":
                let child = try pop(KMLPlaylist.self, forElement: elementName)
                switch stack.last {
                case let tour as KMLTour:
                    tour.playlist = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }

            case "Point":
                let child = try pop(KMLPoint.self, forElement: elementName)
                switch stack.last {
                case let placemark as KMLPlacemark:
                    placemark.geometry = child
                case let multi as KMLMultiGeometry:
                    multi.geometry.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Region":
                let child = try pop(KMLRegion.self, forElement: elementName)
                switch stack.last {
                case let feature as KMLFeature:
                    feature.region = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Snippet":
                let child = try pop(KMLSnippet.self, forElement: elementName)
                
                child.value = buffer
                
                switch stack.last {
                case let feature as KMLFeature:
                    feature.snippets.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "ScreenOverlay":
                let child = try pop(ScreenOverlay.self, forElement: elementName)
                switch stack.last {
                case let kml as KMLRoot:
                    kml.feature = child
                case let container as KMLContainer:
                    container.features.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }

            case "Style":
                let child = try pop(KMLStyle.self, forElement: elementName)
                switch stack.last {
                case let feature as KMLFeature:
                    feature.styleSelector.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "StyleMap":
                let child = try pop(KMLStyleMap.self, forElement: elementName)
                switch stack.last {
                case let feature as KMLFeature:
                    feature.styleSelector.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }

            case "Tour":
                let child = try pop(KMLTour.self, forElement: elementName)
                switch stack.last {
                case let container as KMLContainer:
                    container.features.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }

            case "Track":
                let child = try pop(KMLTrack.self, forElement: elementName)
                switch stack.last {
                case let placemark as KMLPlacemark:
                    placemark.geometry = child
                case let multi as KMLMultiGeometry:
                    multi.geometry.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Update":
                let child = try pop(KMLUpdate.self, forElement: elementName)
                switch stack.last {
                case let control as KMLNetworkLinkControl:
                    control.update = child
                case let animated as AnimatedUpdate:
                    animated.update = child
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            case "Wait":
                let child = try pop(Wait.self, forElement: elementName)
                switch stack.last {
                case let playlist as KMLPlaylist:
                    playlist.items.append(child)
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: child, elementName: elementName)
                }
                
            // MARK: - Scalar values below

            case "altitude":
                let value = CLLocationDistance(buffer) ?? 0.0
                switch stack.last {
                case let lookat as KMLLookAt:
                    lookat.altitude = value
                case let camera as KMLCamera:
                    camera.altitude = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "altitudeMode":
                let value = KMLAltitudeMode(rawValue: buffer) ?? .clampToGround
                switch stack.last {
                case let geometry as KMLGeometry:
                    geometry.altitudeMode = value
                case let lookAt as KMLLookAt:
                    lookAt.altitudeMode = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "balloonVisibility":
                let value = (buffer as NSString).boolValue
                switch stack.last {
                case let feature as KMLFeature:
                    feature.balloonVisibility = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }

            case "bgColor":
                let value = KMLColor(hex: buffer)
                switch stack.last {
                case let style as KMLListStyle:
                    style.bgColor = value
                case let style as KMLBalloonStyle:
                    style.bgColor = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }

            case "color":
                let value = KMLColor(hex: buffer)
                switch stack.last {
                case let style as KMLColorStyle:
                    style.color = value
                case let overlay as KMLOverlay:
                    overlay.color = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "colorMode":
                let value = KMLColorMode(rawValue: buffer) ?? .normal
                switch stack.last {
                case let style as KMLColorStyle:
                    style.colorMode = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
                
            case "coordinates":
                let value = parseCoordinates(buffer)
                switch stack.last {
                case let lineString as KMLLineString:
                    lineString.coordinates = value
                case let point as KMLPoint:
                    if let coordinate = value.first {
                        point.location = coordinate
                    }
                case let linearRing as KMLLinearRing:
                    linearRing.coordinates = value
                    
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "description":
                let value = buffer.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                switch stack.last {
                case let feature as KMLFeature:
                    feature.featureDescription = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "drawOrder":
                let value = Int(buffer) ?? 0
                switch stack.last {
                case let overlay as KMLOverlay:
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
                case let box as KMLAbstractLatLonBox:
                    box.east = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "extrude":
                let value = (buffer as NSString).boolValue
                switch stack.last {
                case let point as KMLPoint:
                    point.extrude = value
                case let track as KMLTrack:
                    track.extrude = value
                case let lineString as KMLLineString:
                    lineString.extrude = value
                case let polygon as KMLPolygon:
                    polygon.extrude = value
                case let linearRing as KMLLinearRing:
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
                case let orientation as KMLOrientation:
                    orientation.heading = value
                case let iconStyle as KMLIconStyle:
                    iconStyle.heading = value
                case let lookat as KMLLookAt:
                    lookat.heading = value
                case let camera as KMLCamera:
                    camera.heading = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "key":
                let value = buffer
                switch stack.last {
                case let pair as KMLStyleMap.Pair:
                    pair.key = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "href":
                guard let value = URL(string: buffer) else { break }
                switch stack.last {
                case let link as KMLBasicLink:
                    link.href = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "latitude":
                guard let value = CLLocationDegrees(buffer) else { break }
                switch stack.last {
                case let lookat as KMLLookAt:
                    lookat.latitude = value
                case let camera as KMLCamera:
                    camera.latitude = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "longitude":
                guard let value = CLLocationDegrees(buffer) else { break }
                switch stack.last {
                case let lookat as KMLLookAt:
                    lookat.longitude = value
                case let camera as KMLCamera:
                    camera.longitude = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "name":
                let value = buffer
                switch stack.last {
                case let kml as KMLDocument:
                    kml.name = value
                case let obj as KMLObject:
                    obj.name = value
                case let author as KMLAuthor:
                    author.nameOrUriOrEmail = [value]
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "north":
                let value = CLLocationDegrees(buffer) ?? 0
                switch stack.last {
                case let box as KMLAbstractLatLonBox:
                    box.north = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "open":
                let value = (buffer as NSString).boolValue
                switch stack.last {
                case let feature as KMLFeature:
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
                case let box as KMLLatLonBox:
                    box.rotation = value
                case let overlay as ScreenOverlay:
                    overlay.rotation = value
                case let overlay as KMLPhotoOverlay:
                    overlay.rotation = value                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }

            case "range":
                let value = Double(buffer) ?? 0
                switch stack.last {
                case let lookat as KMLLookAt:
                    lookat.range = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "scale":
                let value = Double(buffer) ?? 1.0
                switch stack.last {
                case let style as KMLLabelStyle:
                    style.scale = value
                case let style as KMLIconStyle:
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
                case let link as KMLLink:
                    link.refreshInterval = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "refreshMode":
                let value = Icon.RefreshMode(rawValue: buffer) ?? .onChange
                switch stack.last {
                case let link as KMLLink:
                    link.refreshMode = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "roll":
                let value = Double(buffer) ?? 0
                switch stack.last {
                case let camera as KMLCamera:
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
                case let box as KMLAbstractLatLonBox:
                    box.south = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "sourceHref":
                guard let value = URL(string: buffer) else { break }
                switch stack.last {
                case let alias as KMLModel.KMLAlias:
                    alias.sourceHref = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "styleUrl":
                guard let value = URL(string: buffer) else { break }
                switch stack.last {
                case let feature as KMLFeature:
                    feature.styleUrl = value
                case let pair as KMLStyleMap.Pair:
                    pair.styleUrl = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "targetHref":
                guard let value = URL(string: buffer) else { break }
                switch stack.last {
                case let update as KMLUpdate:
                    update.targetHref = value
                case let alias as KMLModel.KMLAlias:
                    alias.targetHref = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "tessellate":
                let value = (buffer as NSString).boolValue
                switch stack.last {
                case let lineString as KMLLineString:
                    lineString.tessellate = value
                case let polygon as KMLPolygon:
                    polygon.tessellate = value
                case let linearRing as KMLLinearRing:
                    linearRing.tessellate = value
                case let track as KMLTrack:
                    track.tessellate = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "text":
                let value = buffer
                switch stack.last {
                case let style as KMLBalloonStyle:
                    style.text = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "tilt":
                let value = Double(buffer) ?? 0
                switch stack.last {
                case let lookat as KMLLookAt:
                    lookat.tilt = value
                case let camera as KMLCamera:
                    camera.tilt = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "viewBoundScale":
                let value = Double(buffer) ?? 1.0
                switch stack.last {
                case let link as KMLLink:
                    link.viewBoundScale = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "visibility":
                let value = (buffer as NSString).boolValue
                switch stack.last {
                case let feature as KMLFeature:
                    feature.visibility = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "west":
                let value = CLLocationDegrees(buffer) ?? 0
                switch stack.last {
                case let box as KMLAbstractLatLonBox:
                    box.west = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
            case "width":
                let value = Double(buffer) ?? 1.0
                switch stack.last {
                case let style as KMLLineStyle:
                    style.width = value
                default:
                    throw ParsingError.unsupportedRelationship(parent: stack.last, child: value, elementName: elementName)
                }
                
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
