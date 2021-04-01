//
//  KMLParserTest.swift
//  QTHTests
//
//  Created by Weston Bustraan on 2/25/21.
//  Copyright © 2021 Weston Bustraan. All rights reserved.
//

import XCTest

@testable import KMLKit
class KMLParserTest: XCTestCase {
    
    let bundle = Bundle(for: KMLParserTest.self)
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func getSampleFile(_ resource: String, type: String) throws -> URL {
        let path = bundle.path(forResource: resource, ofType: type)!
        return URL(fileURLWithPath: path)
    }
    
    func testParseKMLSample1() throws {
        let kmzFile = try getSampleFile("KML_Samples", type: "kml")
        
        let kml = try KMLParser.parse(file: kmzFile)
        print(kml)
    }
    
    func testParseDateTimeAsComponents() throws {
        
        let parser = KMLParser()
        
        var components = try parser.parseDateTimeAsComponents("1997")
        XCTAssertEqual(1997, components.year)
        
        components = try parser.parseDateTimeAsComponents("1997-07")
        XCTAssertEqual(1997, components.year)
        XCTAssertEqual(7, components.month)
        
        components = try parser.parseDateTimeAsComponents("1997-07-16")
        XCTAssertEqual(1997, components.year)
        XCTAssertEqual(7, components.month)
        XCTAssertEqual(16, components.day)
        
        
        var tz = TimeZone(identifier: "UTC")
        var expectedComponents = DateComponents(timeZone: tz, year: 1997, month: 07, day: 16, hour: 7, minute: 30, second: 15)
        var expectedDate = Calendar.current.date(from: expectedComponents)
        
        components = try parser.parseDateTimeAsComponents("1997-07-16T07:30:15Z")
        var date = Calendar.current.date(from: components)
        XCTAssertEqual(expectedDate, date)
        
        tz = TimeZone(secondsFromGMT: 3 * 60 * 60)
        expectedComponents = DateComponents(timeZone: tz, year: 1997, month: 07, day: 16, hour: 10, minute: 30, second: 15)
        expectedDate = Calendar.current.date(from: expectedComponents)
        
        components = try parser.parseDateTimeAsComponents("1997-07-16T10:30:15+03:00")
        date = Calendar.current.date(from: components)
        XCTAssertEqual(expectedDate, date)
        
    }
    
    func testParseKMZ() throws {
        
        let kmzFile = try getSampleFile("aprsfi_export_W8AGT-9_20210222_122629_20210225_122629", type: "kmz")
        
        let kml = try KMLParser.parse(file: kmzFile)
        let document = kml.findFirstFeature(ofType: KMLDocument.self)!
        XCTAssertEqual("aprs", document.id)
        
        XCTAssertEqual(1, document.styleSelector.count)
        let style = document.styleSelector.first as! KMLStyle
        XCTAssertEqual("t4856505", style.id)
        
        let labelStyle = style.labelStyle!
        XCTAssertEqual("ffa8ff00", labelStyle.color.kmlHex)
        XCTAssertEqual(0.75, labelStyle.scale)
        
        let iconStyle = style.iconStyle!
        XCTAssertEqual(0.75, iconStyle.scale)
        
        let icon = iconStyle.icon!
        XCTAssertEqual(URL(string: "files/sym/f24/p6ap6a.png"), icon.href)
        
        let lineStyle = style.lineStyle!
        XCTAssertEqual("fffc00ff", lineStyle.color.kmlHex)
        XCTAssertEqual(.normal, lineStyle.colorMode)
        XCTAssertEqual(2, lineStyle.width)
        
        let polyStyle = style.polyStyle!
        XCTAssertEqual("7f00ff00", polyStyle.color.kmlHex)
        
        let placemark = document.features.first as! KMLPlacemark
        XCTAssertEqual("W8AGT-9", placemark.name)
        XCTAssertEqual("<a href=\'http://aprs.fi/?call=W8AGT-9\'>[click here to track on aprs.fi]</a><br />\n2021-02-25 12:24:52z<br />\n27 MPH\n 179°\n 817 ft\n<br />", placemark.featureDescription)
        
        XCTAssertEqual(1, placemark.snippets.count)
        let snippet = placemark.snippets.first!
        XCTAssertEqual("(27 MPH)", snippet.value)
        XCTAssertEqual(2, snippet.maxLines)
        
        XCTAssertEqual("t4856505", placemark.styleUrl?.fragment)
        
        let multiGeometry = placemark.geometry as! KMLMultiGeometry
        
        XCTAssertEqual(2, multiGeometry.geometry.count)
        
        let point = multiGeometry.geometry[0] as! KMLPoint
        XCTAssertEqual(.absolute, point.altitudeMode)
        XCTAssertEqual(CLLocationDegrees(42.74583), point.location.coordinate.latitude)
        XCTAssertEqual(CLLocationDegrees(-85.66200), point.location.coordinate.longitude)
        XCTAssertEqual(CLLocationDistance(249.00), point.location.altitude)
        
        let lineString = multiGeometry.geometry[1] as! KMLLineString
        XCTAssertTrue(lineString.tessellate)
        XCTAssertTrue(lineString.extrude)
        XCTAssertEqual(.absolute, lineString.altitudeMode)
        
        let coordinates = lineString.coordinates
        
        XCTAssertEqual(275, coordinates.count)
        
        let pt1 = coordinates.first!
        XCTAssertEqual(CLLocationDegrees(43.03250), pt1.coordinate.latitude)
        XCTAssertEqual(CLLocationDegrees(-85.62483), pt1.coordinate.longitude)
        XCTAssertEqual(CLLocationDistance(220.00), pt1.altitude)
        
        let pt2 = coordinates.last!
        XCTAssertEqual(CLLocationDegrees(42.78217), pt2.coordinate.latitude)
        XCTAssertEqual(CLLocationDegrees(-85.66333), pt2.coordinate.longitude)
        XCTAssertEqual(CLLocationDistance(249.00), pt2.altitude)
        
        
    }
    
    func testParse_address_example() throws {
        
        let kmlFile = try getSampleFile("address_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let placemark = kml.feature as! KMLPlacemark
        XCTAssertEqual("123 Any Str.", placemark.address)
        
        
    }
    
    func testParse_altitudemode_reference() throws {
        
        let kmlFile = try getSampleFile("altitudemode_reference", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let placemark = kml.feature as! KMLPlacemark
        let lookat = placemark.view as! KMLLookAt
        XCTAssertEqual(.relativeToSeaFloor, lookat.altitudeMode)
        
        let lineString = placemark.geometry as! KMLLineString
        XCTAssertEqual(.relativeToSeaFloor, lineString.altitudeMode)
        
    }
    
    func testParse_animatedupdate_example() throws {
        
        let kmlFile = try getSampleFile("animatedupdate_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let tour = kml.findFeatures(ofType: KMLTour.self).first!
        
        XCTAssertEqual(3, tour.playlist.items.count)
        
        for item in tour.playlist.items {
            
            switch item {
            case let animatedUpdate as KMLTourAnimatedUpdate:
                XCTAssertEqual(6.5, animatedUpdate.duration)
            case let flyTo as KMLTourFlyTo:
                XCTAssertEqual(4.1, flyTo.duration)
                
                let camera = flyTo.view as! KMLCamera
                XCTAssertEqual(170.157, camera.longitude)
                XCTAssertEqual(-43.671, camera.latitude)
                XCTAssertEqual(9700, camera.altitude)
                XCTAssertEqual(-6.333, camera.heading)
                XCTAssertEqual(33.5, camera.tilt)
                XCTAssertEqual(0, camera.roll)
                
            case let wait as KMLTourWait:
                XCTAssertEqual(2.4, wait.duration)
                
            default:
                XCTFail("Unexpected item \(item)")
            }
            
        }
    }
    
    func testParse_author_example() throws {
        
        let kmlFile = try getSampleFile("author_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let document = kml.findFirstFeature(ofType: KMLDocument.self)!
        
        XCTAssertEqual("J. K. Rowling", document.author?.name.first)
        XCTAssertEqual(URL(string: "http://www.harrypotter.com"), document.link?.href)
        
        let hogwarts = document.features[0] as! KMLPlacemark
        XCTAssertEqual("Hogwarts", hogwarts.name)
        let hogwartsPoint = hogwarts.geometry as! KMLPoint
        XCTAssertEqual(1, hogwartsPoint.location.coordinate.latitude)
        XCTAssertEqual(1, hogwartsPoint.location.coordinate.longitude)
        
        let littleHangleton = document.features[1] as! KMLPlacemark
        XCTAssertEqual("Little Hangleton", littleHangleton.name)
        let littleHangletonPoint = littleHangleton.geometry as! KMLPoint
        XCTAssertEqual(1, littleHangletonPoint.location.coordinate.longitude)
        XCTAssertEqual(2, littleHangletonPoint.location.coordinate.latitude)
        
        
    }
    
    func testParse_balloonstyle_example() throws {
        
        let kmlFile = try getSampleFile("balloonstyle_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let document = kml.findFirstFeature(ofType: KMLDocument.self)!
        let style = document.styleSelector.first as! KMLStyle
        let balloonStyle = style.balloonStyle
        
        XCTAssertEqual("ffffffbb", balloonStyle?.bgColor?.kmlHex)
        XCTAssertEqual("<b><font color=\"#CC0000\" size=\"+3\">$[name]</font></b>\n      <br/><br/>\n      <font face=\"Courier\">$[description]</font>\n      <br/><br/>\n      Extra text that will appear in the description balloon\n      <br/><br/>\n      <!-- insert the to/from hyperlinks -->\n      $[geDirections]", balloonStyle?.text)
        
        
        
        let placemark = document.findFirstFeature(ofType: KMLPlacemark.self)!
        XCTAssertEqual("BalloonStyle", placemark.name)
        XCTAssertEqual("An example of BalloonStyle", placemark.featureDescription)
        XCTAssertEqual("exampleBalloonStyle", placemark.styleUrl?.fragment)
        
        let point = placemark.geometry as! KMLPoint
        XCTAssertEqual(-122.370533, point.location.coordinate.longitude)
        XCTAssertEqual(37.823842, point.location.coordinate.latitude)
        XCTAssertEqual(0, point.location.altitude)
        
        
    }
    
    func testParse_balloonvisibility_example() throws {
        
        let kmlFile = try getSampleFile("balloonvisibility_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        
        let placemark = kml.feature as! KMLPlacemark
        XCTAssertTrue(placemark.balloonVisibility)
        
    }
    
    func testParse_balloonvisibility_tourexample() throws {
        
        let kmlFile = try getSampleFile("balloonvisibility_tourexample", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let tour = kml.findFeatures(ofType: KMLTour.self).first!
        XCTAssertEqual("Play me", tour.name)
        
        XCTAssertEqual(11, tour.playlist.items.count)
        
        let changes = tour.playlist
            .compactMap({ ($0 as? KMLTourAnimatedUpdate)?.update })
            .flatMap({ $0.items })
            .compactMap({ $0 as? KMLChange })
        
        let placemarkChanges: [KMLPlacemark] = changes.compactMap { $0.objects.first as? KMLPlacemark }
        XCTAssertEqual(5, placemarkChanges.count)
        
        
        let balloonVisibilityCount = placemarkChanges.reduce(0, { $0 + ($1.balloonVisibility as NSNumber).intValue })
        XCTAssertEqual(3, balloonVisibilityCount)
        
        let placemarks = kml.findFeatures(ofType: KMLPlacemark.self)
        
        let placemarkIds = placemarks.map { $0.id }
        XCTAssertEqual(["underwater1", "underwater2", "onland"], placemarkIds)
        
    }
    
    func testParse_document_example() throws {
        
        let kmlFile = try getSampleFile("document_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let document = kml.findFirstFeature(ofType: KMLDocument.self)
        XCTAssertNotNil(document)
    }
    
    func testParse_embedded_video_sample() throws {
        
        let kmlFile = try getSampleFile("embedded_video_sample", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let placemark = kml.findFirstFeature(ofType: KMLPlacemark.self)!
        
        XCTAssert(placemark.featureDescription!.contains("application/x-shockwave-flash"))
        
    }
    
    func testParse_folder_example() throws {
        
        let kmlFile = try getSampleFile("folder_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let folder = kml.findFirstFeature(ofType: KMLFolder.self)!
        XCTAssertEqual(3, folder.count)
        XCTAssertEqual("Folder.kml", folder.name)
        XCTAssertEqual("A folder is a container that can hold multiple other objects", folder.featureDescription)
        XCTAssertTrue(folder.open)
        
    }
    
    
    func testParse_groundoverlay_example() throws {
        
        let kmlFile = try getSampleFile("groundoverlay_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let groundOverlay = kml.findFirstFeature(ofType: KMLGroundOverlay.self)!
        
        XCTAssertEqual("GroundOverlay.kml", groundOverlay.name)
        XCTAssertEqual("7fffffff", groundOverlay.color?.kmlHex)
        XCTAssertEqual(1, groundOverlay.drawOrder)
        
        let icon = groundOverlay.icon!
        XCTAssertEqual(URL(string: "http://www.google.com/intl/en/images/logo.gif"), icon.href)
        XCTAssertEqual(.onInterval, icon.refreshMode)
        XCTAssertEqual(86400, icon.refreshInterval)
        XCTAssertEqual(0.75, icon.viewBoundScale)
        
        let box = groundOverlay.extent as! KMLLatLonBox
        XCTAssertEqual(37.83234, box.north)
        XCTAssertEqual(37.832122, box.south)
        XCTAssertEqual(-122.373033, box.east)
        XCTAssertEqual(-122.373724, box.west)
        XCTAssertEqual(45, box.rotation)
        
    }
    
    func testParse_iconstyle_example() throws {
        
        let kmlFile = try getSampleFile("iconstyle_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let document = kml.findFirstFeature(ofType: KMLDocument.self)!
        let style = document.findStyle(withId: "randomColorIcon")!
        let iconStyle = style.iconStyle!
        
        XCTAssertEqual("ff00ff00", iconStyle.color.kmlHex)
        XCTAssertEqual(.random, iconStyle.colorMode)
        XCTAssertEqual(1.1, iconStyle.scale)
        
        let icon = iconStyle.icon!
        XCTAssertEqual(URL(string: "http://maps.google.com/mapfiles/kml/pal3/icon21.png"), icon.href)
        
        
    }
    
    func testParse_labelstyle_example() throws {
        
        let kmlFile = try getSampleFile("labelstyle_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let document = kml.findFirstFeature(ofType: KMLDocument.self)!
        let style = document.findStyle(withId: "randomLabelColor")!
        let labelStyle = style.labelStyle!
        
        
        XCTAssertEqual("ff0000cc", labelStyle.color.kmlHex)
        XCTAssertEqual(.random, labelStyle.colorMode)
        XCTAssertEqual(1.5, labelStyle.scale)
        
    }
    
    func testParse_latlonquad_example() throws {
        
        let kmlFile = try getSampleFile("latlonquad_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let overlay = kml.findFirstFeature(ofType: KMLGroundOverlay.self)!
        let latlonquad = overlay.extent as! KMLLatLonQuad
        
        
        let expectedCoords = [
            CLLocation(latitude: 44.160723, longitude: 81.601884),
            CLLocation(latitude: 43.665148, longitude: 83.529902),
            CLLocation(latitude: 44.248831, longitude: 82.947737),
            CLLocation(latitude: 44.321015, longitude: 81.509322)
        ]
        
        
        let expectedLongitudes = expectedCoords.compactMap { $0.coordinate.longitude }
        let parsedLongitudes = latlonquad.coordinates.compactMap { $0.coordinate.longitude }
        XCTAssertEqual(expectedLongitudes, parsedLongitudes)
        
        let expectedLatitudes = expectedCoords.compactMap { $0.coordinate.latitude }
        let parsedLatitudes = latlonquad.coordinates.compactMap { $0.coordinate.latitude }
        XCTAssertEqual(expectedLatitudes, parsedLatitudes)
        
        
    }
    
    func testParse_linearring_example() throws {
        
        let kmlFile = try getSampleFile("linearring_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        let placemark = kml.findFirstFeature(ofType: KMLPlacemark.self)!
        let polygon = placemark.geometry as! KMLPolygon
        
        let linearRing = polygon.outerBoundaryIs.linearRing
        
        let expectedLongitudes: [CLLocationDegrees] = [-122.365662, -122.365202, -122.364581, -122.365038, -122.365662]
        let parsedLongitudes = linearRing.coordinates.compactMap { $0.coordinate.longitude }
        XCTAssertEqual(expectedLongitudes, parsedLongitudes)
        
        
        let expectedLatitudes: [CLLocationDegrees] = [37.826988, 37.826302, 37.82655, 37.827237, 37.826988]
        let parsedLatitudes = linearRing.coordinates.compactMap { $0.coordinate.latitude }
        XCTAssertEqual(expectedLatitudes, parsedLatitudes)
        
    }
    
    func testParse_linestring_example() throws {
        
        let kmlFile = try getSampleFile("linestring_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let lineStrings = kml.findFeatures(ofType: KMLPlacemark.self).compactMap({ $0.geometry as? KMLLineString })
        XCTAssertEqual(2, lineStrings.count)
        
        var lineString = lineStrings[0]
        XCTAssertTrue(lineString.extrude)
        XCTAssertTrue(lineString.tessellate)
        
        for (i, coordinate) in lineString.coordinates.enumerated() {
            if i == 0 {
                XCTAssertEqual(-122.364383, coordinate.coordinate.longitude)
                XCTAssertEqual(37.824664, coordinate.coordinate.latitude)
                XCTAssertEqual(0, coordinate.altitude)
            } else {
                XCTAssertEqual(-122.364152, coordinate.coordinate.longitude)
                XCTAssertEqual(37.824322, coordinate.coordinate.latitude)
                XCTAssertEqual(0, coordinate.altitude)
            }
        }
        
        lineString = lineStrings[1]
        XCTAssertTrue(lineString.extrude)
        XCTAssertTrue(lineString.tessellate)
        
        for (i, coordinate) in lineString.coordinates.enumerated() {
            if i == 0 {
                XCTAssertEqual(-122.364167, coordinate.coordinate.longitude)
                XCTAssertEqual(37.824787, coordinate.coordinate.latitude)
                XCTAssertEqual(50, coordinate.altitude)
            } else {
                XCTAssertEqual(-122.363917, coordinate.coordinate.longitude)
                XCTAssertEqual(37.824423, coordinate.coordinate.latitude)
                XCTAssertEqual(50, coordinate.altitude)
            }
        }
        
    }
    
    func testParse_liststyle_example() throws {
        
        let kmlFile = try getSampleFile("liststyle_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        let document = kml.findFirstFeature(ofType: KMLDocument.self)!
        let placemarks = kml.findFeatures(ofType: KMLPlacemark.self)
        XCTAssertEqual(9, placemarks.count)
        
        let foldersWithListStyle = kml.findFeatures(ofType: KMLFolder.self).filter({ $0.styleUrl != nil })
        XCTAssertEqual(3, foldersWithListStyle.count)
        
        for folder in foldersWithListStyle {
            guard let style = document.findStyle(withUrl: folder.styleUrl) else {
                XCTFail("Could not get style for \(String(describing: folder.styleUrl))")
                continue
            }
            
            let listStyle = style.listStyle!
            
            switch style.id {
            case "bgColorExample":
                XCTAssertEqual("ff336699", listStyle.bgColor.kmlHex)
            case "checkHideChildrenExample":
                XCTAssertEqual(.checkHideChildren, listStyle.listItemType)
            case "radioFolderExample":
                XCTAssertEqual(.radioFolder, listStyle.listItemType)
            default:
                XCTFail("Unexpected style id \(style.id ?? "")")
            }
        }
        
    }
    
    func testParse_lookat_example() throws {
        
        let kmlFile = try getSampleFile("lookat_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let placemark = kml.findFirstFeature(ofType: KMLPlacemark.self)!
        
        let expectedDate = Date(timeIntervalSince1970: 757400400)
        XCTAssertEqual(expectedDate, placemark.view?.time?.asDate())
        
        let lookAt = placemark.view as! KMLLookAt
        XCTAssertEqual(37.81, lookAt.latitude)
        XCTAssertEqual(-122.363, lookAt.longitude)
        XCTAssertEqual(2000, lookAt.altitude)
        XCTAssertEqual(500, lookAt.range)
        XCTAssertEqual(45, lookAt.tilt)
        XCTAssertEqual(0, lookAt.heading)
        XCTAssertEqual(.relativeToGround, lookAt.altitudeMode)
        
    }
    
    func testParse_networklinkcontrol_example() throws {
        
        let kmlFile = try getSampleFile("networklinkcontrol_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let networkLinkControl = kml.networkLinkControl!
        XCTAssertEqual("This is a pop-up message. You will only see this once", networkLinkControl.message)
        XCTAssertEqual("cookie=sometext", networkLinkControl.cookie)
        XCTAssertEqual("New KML features", networkLinkControl.linkName)
        XCTAssertEqual("KML now has new features available!", networkLinkControl.linkDescription)
        
    }
    
    func testParse_photooverlay_example() throws {
        let kmlFile = try getSampleFile("photooverlay_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let photoOverlay = kml.findFirstFeature(ofType: KMLPhotoOverlay.self)!
        XCTAssertEqual("A simple non-pyramidal photo", photoOverlay.name)
        XCTAssertEqual("High above the ocean", photoOverlay.featureDescription)
        
        let icon = photoOverlay.icon!
        XCTAssertEqual(URL(string: "small-photo.jpg"), icon.href)
        
        let viewVolume = photoOverlay.viewVolume!
        XCTAssertEqual(1000, viewVolume.near)
        XCTAssertEqual(-60, viewVolume.leftFov)
        XCTAssertEqual(60, viewVolume.rightFov)
        XCTAssertEqual(-45, viewVolume.bottomFov)
        XCTAssertEqual(45, viewVolume.topFov)
        
    }
    
    func testParse_placemark_example() throws {
        
        let kmlFile = try getSampleFile("placemark_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let placemark = kml.findFirstFeature(ofType: KMLPlacemark.self)!
        XCTAssertEqual("Feature.kml", placemark.name)
        
        let snippet = placemark.snippets.first!
        XCTAssertEqual("The snippet is a way of\n    providing an alternative\n    description that will be\n    shown in the List view.", snippet.value)
        
        XCTAssert(placemark.featureDescription!.contains(#"<a href="http://doc.trolltech.com/3.3/qstylesheet.html">"#))
        
        let point = placemark.geometry as! KMLPoint
        XCTAssertEqual(-122.378927, point.location.coordinate.longitude)
        XCTAssertEqual(37.826793, point.location.coordinate.latitude)
    }
    
    func testParse_polygon_example() throws {
        
        let kmlFile = try getSampleFile("polygon_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let placemark = kml.findFirstFeature(ofType: KMLPlacemark.self)!
        let polygon = placemark.geometry as! KMLPolygon
        
        XCTAssertNotNil(polygon.outerBoundaryIs)
        XCTAssertNotNil(polygon.innerBoundaryIs.first)
        XCTAssertEqual(5, polygon.innerBoundaryIs.first?.linearRing.coordinates.count)
        
    }
    
    func testParse_polystyle_example() throws {
        
        let kmlFile = try getSampleFile("polystyle_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        let document = kml.findFirstFeature(ofType: KMLDocument.self)!
        
        let style = document.findStyle(withId: "examplePolyStyle")!
        let polyStyle = style.polyStyle!
        XCTAssertEqual("ff0000cc", polyStyle.color.kmlHex)
        XCTAssertEqual(.random, polyStyle.colorMode)
        
    }
    
    func testParse_simplefield_example() throws {
        
        let kmlFile = try getSampleFile("simplefield_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        let document = kml.findFirstFeature(ofType: KMLDocument.self)!
        let schema = document.schema!
        
        XCTAssertEqual("TrailHeadType", schema.name)
        XCTAssertEqual("TrailHeadTypeId", schema.id)
        
        XCTAssertEqual(3, schema.fields.count)
        
        var field = schema.fields[0]
        XCTAssertEqual("string", field.type)
        XCTAssertEqual("TrailHeadName", field.name)
        XCTAssertEqual("<b>Trail Head Name</b>", field.displayName)
        
        field = schema.fields[1]
        XCTAssertEqual("double", field.type)
        XCTAssertEqual("TrailLength", field.name)
        XCTAssertEqual("<i>The length in miles</i>", field.displayName)
        
        field = schema.fields[2]
        XCTAssertEqual("int", field.type)
        XCTAssertEqual("ElevationGain", field.name)
        XCTAssertEqual("<i>change in altitude</i>", field.displayName)
        
    }
    
    func testParse_stylemap_example() throws {
        
        let kmlFile = try getSampleFile("stylemap_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let document = kml.findFirstFeature(ofType: KMLDocument.self)!
        let styleMap = document.styleSelector.compactMap({ $0 as? KMLStyleMap }).first!
        
        
        for (key, value) in styleMap {
            guard let styleRef = value as? KMLStyleRef else {
                XCTFail("Got an unexpected value \(value)")
                continue
            }
            
            switch key {
            case "normal":
                XCTAssertEqual("normalState", styleRef.styleUrl.fragment)
            case "highlight":
                XCTAssertEqual("highlightState", styleRef.styleUrl.fragment)
            default:
                XCTFail("Unexpected key \(key)")
            }
        }
    }
    
    func testParse_timespan_example() throws {
        
        let kmlFile = try getSampleFile("timespan_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let placeMarks = kml.findFeatures(ofType: KMLPlacemark.self)
        XCTAssertEqual(2, placeMarks.count)
        
        let cameras = placeMarks.compactMap({ $0.view as? KMLCamera })
        XCTAssertEqual(2, cameras.count)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = .withInternetDateTime
        
        var expectedDate = dateFormatter.date(from: "1946-07-29T05:00:00-08:00")!
        var parsedDate = cameras[0].time!.asDate()
        XCTAssertEqual(expectedDate, parsedDate)
        
        expectedDate = dateFormatter.date(from: "2002-07-09T19:00:00-08:00")!
        parsedDate = cameras[1].time!.asDate()
        XCTAssertEqual(expectedDate, parsedDate)
        
    }
    
    func testParse_tourprimitive_example() throws {
        
        let kmlFile = try getSampleFile("tourprimitive_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        
        let tour = kml.findFirstFeature(ofType: KMLTour.self)!
        
        let durations: [Double] = tour.playlist.compactMap { (tourPrimitive) in
            switch tourPrimitive {
            case let primitive as KMLTourPrimitiveDuration:
                return primitive.duration
            default:
                return 0
            }
        }
        
        XCTAssertEqual([6.5, 4.1, 2.4], durations)
        
    }
    
    func testParse_track_example() throws {
        
        let kmlFile = try getSampleFile("track_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let placemark = kml.findFirstFeature(ofType: KMLPlacemark.self)!
        let track = placemark.geometry as! KMLTrack
        
        let ss = [9, 35, 44, 53, 54, 55, 56]
        let dist: [CLLocationDistance] = [0, 241.451, 115.104, 123.119, 13.469, 13.58, 13.580, 13.580]
        
        var prevLocation: CLLocation?
        for (i, location) in track.coordinates.enumerated() {
            if let prevLocation = prevLocation {
                
                let elapsed = location.timestamp.timeIntervalSince(prevLocation.timestamp)
                let expectedElapsed = TimeInterval(ss[i] - ss[i-1])
                XCTAssertEqual(expectedElapsed, elapsed)
                
                let distance = location.distance(from: prevLocation)
                XCTAssertEqual(distance, dist[i], accuracy: 0.001)
                
            }
            prevLocation = location
        }
        
        
    }
    
    func testParse_track_extended_example() throws {
        
        let kmlFile = try getSampleFile("track_extended_example", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let document = kml.findFirstFeature(ofType: KMLDocument.self)!
        
        XCTAssertEqual("GPS device", document.name)
        XCTAssertEqual("Created Wed Jun 2 15:33:39 2010", document.snippets.first?.value)
        
        
        var expectedIds = ["track_n", "track_h", "multiTrack_n", "multiTrack_h", "waypoint_n", "waypoint_h", "lineStyle"]
        
        let styleIds = document.styleSelector.compactMap({ ($0 as? KMLStyle)?.id })
        XCTAssertEqual(expectedIds, styleIds)
        
        expectedIds = ["track", "multiTrack", "waypoint"]
        let styleMapIds = document.styleSelector.compactMap({ ($0 as? KMLStyleMap)?.id })
        XCTAssertEqual(expectedIds, styleMapIds)
        
        
        var expectedKeys = [String]()
        
        let schema = document.schema!
        XCTAssertEqual(3, schema.fields.count)
        for (i, field) in schema.fields.enumerated() {
            expectedKeys.append(field.name!)
            switch i {
            case 0:
                XCTAssertEqual("heartrate", field.name)
                XCTAssertEqual("int", field.type)
                XCTAssertEqual("Heart Rate", field.displayName)
            case 1:
                XCTAssertEqual("cadence", field.name)
                XCTAssertEqual("int", field.type)
                XCTAssertEqual("Cadence", field.displayName)
            case 2:
                XCTAssertEqual("power", field.name)
                XCTAssertEqual("float", field.type)
                XCTAssertEqual("Power", field.displayName)
            default:
                XCTFail("Unexpected field")
            }
            
        }
        
        let placemark = document.findFirstFeature(ofType: KMLPlacemark.self)!
        
        let track = placemark.geometry as! KMLTrack
        let schemaData = track.extendedData!.schemaData.first!
        let keys = Array(schemaData.data.keys)
        
        XCTAssertEqual(expectedKeys.sorted(), keys.sorted())
        
        let cadenceData = (schemaData.data["cadence"] as! [String]).compactMap(Int.init)
        XCTAssertEqual(749, cadenceData.reduce(0, +))
        
        let heartrateData = (schemaData.data["heartrate"] as! [String]).compactMap(Int.init)
        XCTAssertEqual(1225, heartrateData.reduce(0, +))
        
        let powerData = (schemaData.data["power"] as! [String]).compactMap(Double.init)
        XCTAssertEqual(1371.0, powerData.reduce(0, +))
        
    }
    
    func testParse_kitchen_sink() throws {
        
        
        let kmlFile = try getSampleFile("kitchen_sink", type: "kml")
        
        let kml = try KMLParser.parse(file: kmlFile)
        
        let networkLinkControl = kml.networkLinkControl!
        XCTAssertEqual("Link Snippet", networkLinkControl.linkSnippet)
        XCTAssertEqual(60, networkLinkControl.maxSessionLength)
        XCTAssertEqual(0.2, networkLinkControl.minRefreshPeriod)
        
        
        let document = kml.findFirstFeature(ofType: KMLDocument.self)!
        
        XCTAssertEqual(1, document.addressDetails.count)
        
        XCTAssertEqual("George Jetson", document.author?.name.first)
        XCTAssertEqual("george.jetson@maildrop.cc", document.author?.email.first)
        XCTAssertEqual(URL(string: "http://www.spacelysprocketsinc.com/index.html"), document.author?.uri.first)
        
        let style = document.styleSelector.first as! KMLStyle
        
        XCTAssertEqual(CGPoint(x: 3, y: 4), style.iconStyle?.hotSpot)
        
        XCTAssertEqual(3, style.listStyle!.maxSnippetLines)
        XCTAssertEqual(.open, style.listStyle?.itemIcon.first?.state)
        
        XCTAssertTrue(style.polyStyle!.fill)
        XCTAssertFalse(style.polyStyle!.outline)
        
        XCTAssertEqual("ff0000ff", style.balloonStyle?.textColor?.kmlHex)
        
        
        let photoOverlay = document.findFirstFeature(ofType: KMLPhotoOverlay.self)!
        XCTAssertEqual("(555) 867-5309", photoOverlay.phoneNumber)
        XCTAssertEqual(.sphere, photoOverlay.shape)
        
        
        let imagePyramid = photoOverlay.imagePyramid!
        XCTAssertEqual(512, imagePyramid.tileSize)
        XCTAssertEqual(1024, imagePyramid.maxWidth)
        XCTAssertEqual(1024, imagePyramid.maxHeight)
        XCTAssertEqual(.lowerLeft, imagePyramid.gridOrigin)
        
        let region = photoOverlay.region!
        
        let extent = region.extent as! KMLLatLonAltBox
        XCTAssertEqual(43.374, extent.north)
        XCTAssertEqual(42.983, extent.south)
        XCTAssertEqual(-0.335, extent.east)
        XCTAssertEqual(-1.423, extent.west)
        XCTAssertEqual(1, extent.minAltitude)
        XCTAssertEqual(10000, extent.maxAltitude)
        
        let lod = region.lod!
        XCTAssertEqual(0.01, lod.minLodPixels)
        XCTAssertEqual(-1.02, lod.maxLodPixels)
        XCTAssertEqual(3.4, lod.minFadeExtent)
        XCTAssertEqual(4.5, lod.maxFadeExtent)
        
        let tour = kml.findFirstFeature(ofType: KMLTour.self)!
        
        XCTAssertEqual(2, tour.playlist.items.count)
        for item in tour.playlist {
            
            switch item {
            case let tourControl as KMLTourControl:
                XCTAssertEqual(.pause, tourControl.mode)
            case let soundCue as KMLTourSoundCue:
                XCTAssertEqual(URL(string: "http://www.example.com/audio/trumpets.mp3"), soundCue.href)
                XCTAssertEqual(0.5, soundCue.delayedStart)
            default:
                XCTFail("Unexpected item type \(item)")
            }
            
        }
        
        let placemark = kml.findFirstFeature(ofType: KMLPlacemark.self)!
        
        let camera = placemark.view as! KMLCamera
        XCTAssertEqual(1, camera.options.count)
        XCTAssertEqual("zoom", camera.options.first?.name)
        XCTAssertEqual(true, camera.options.first?.enabled)
        
        
        let geometry = placemark.geometry as! KMLMultiGeometry
        
        let model = geometry.geometry.removeFirst() as! KMLModel
        
        XCTAssertEqual("khModel543", model.id)
        XCTAssertEqual(-118.9813220168456, model.location.coordinate.latitude)
        XCTAssertEqual(39.55375305703105, model.location.coordinate.longitude)
        XCTAssertEqual(1223, model.location.altitude)
        XCTAssertEqual(45.0, model.orientation.heading)
        XCTAssertEqual(10.0, model.orientation.tilt)
        XCTAssertEqual(0.0, model.orientation.roll)
        XCTAssertEqual(1.0, model.scale.x)
        XCTAssertEqual(1.0, model.scale.y)
        XCTAssertEqual(1.0, model.scale.z)
        XCTAssertEqual(URL(string: "house.dae"), model.link?.href)
        XCTAssertEqual(.onChange, model.link?.refreshMode)
        
        XCTAssertEqual(3, model.resourceMap.count)
        
        let targetHref = model.resourceMap["CU-Macky-Back-NorthnoCulling.jpg"]
        XCTAssertEqual("../files/CU-Macky-Back-NorthnoCulling.jpg", targetHref)
        
        let multiTrack = geometry.geometry.removeFirst() as! KMLMultiTrack
        XCTAssertEqual(2, multiTrack.tracks.count)
    }
    
    func testParseLibKMLExamples() throws {
        
        let kmlParser = KMLParser()
        kmlParser.strict = false // Turn off strict so that the unknown elements do not result in errors

        let subdirs = try XCTUnwrap(bundle.urls(forResourcesWithExtension: nil, subdirectory: "testdata"))

        var filesParsed = 0
        
        for subdir in subdirs {
            
            guard subdir.hasDirectoryPath else { continue }
            
            let kmls = bundle.urls(forResourcesWithExtension: "kml", subdirectory: "testdata/\(subdir.lastPathComponent)") ?? []
            
            for kmlFile in kmls {
                do {
                    let xml = try String(contentsOf: kmlFile)
                    
                    // Make sure it's not a fragment
                    guard xml.contains("<kml") else {
                        continue
                    }
                    
                    XCTAssertNoThrow(try kmlParser.parse(file: kmlFile), "Error in \(kmlFile)")
                    filesParsed += 1
                } catch {
                    XCTFail("Failed to parse \(kmlFile): \(error)")
                }
            }
        }
        
        XCTAssertEqual(59, filesParsed)
        
    }
    
}
