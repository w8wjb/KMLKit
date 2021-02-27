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
    
    func testParseKMZ() throws {
        
        let kmzFile = try getSampleFile("aprsfi_export_W8AGT-9_20210222_122629_20210225_122629", type: "kmz")
        
        let kml = try KMLParser.parse(file: kmzFile)
        let document = kml.findFirstFeatures(ofType: KMLDocument.self)!
        XCTAssertEqual("aprs", document.id)
        
        XCTAssertEqual(1, document.styleSelector.count)
        let style = document.styleSelector.first as! KMLStyle
        XCTAssertEqual("t4856505", style.id)
        
        let labelStyle = style.labelStyle!
        XCTAssertEqual("#ffa8ff00", labelStyle.color.hexRGBaColor)
        XCTAssertEqual(0.75, labelStyle.scale)
        
        let iconStyle = style.iconStyle!
        XCTAssertEqual(0.75, iconStyle.scale)
        
        let icon = iconStyle.icon!
        XCTAssertEqual(URL(string: "files/sym/f24/p6ap6a.png"), icon.href)

        let lineStyle = style.lineStyle!
        XCTAssertEqual("#fffc00ff", lineStyle.color.hexRGBaColor)
        XCTAssertEqual(.normal, lineStyle.colorMode)
        XCTAssertEqual(2, lineStyle.width)
        
        let polyStyle = style.polyStyle!
        XCTAssertEqual("#7f00ff00", polyStyle.color.hexRGBaColor)
        
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
    
    func testParse_altitudemode_reference() throws {
        
        let kmlFile = try getSampleFile("altitudemode_reference", type: "kml")

        let kml = try KMLParser.parse(file: kmlFile)
        
        let placemark = kml.feature as! KMLPlacemark
        let lookat = placemark.abstractView as! KMLLookAt
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
            case let animatedUpdate as AnimatedUpdate:
                XCTAssertEqual(6.5, animatedUpdate.duration)
            case let flyTo as FlyTo:
                XCTAssertEqual(4.1, flyTo.duration)
                
                let camera = flyTo.view as! KMLCamera
                XCTAssertEqual(170.157, camera.longitude)
                XCTAssertEqual(-43.671, camera.latitude)
                XCTAssertEqual(9700, camera.altitude)
                XCTAssertEqual(-6.333, camera.heading)
                XCTAssertEqual(33.5, camera.tilt)
                XCTAssertEqual(0, camera.roll)
                
            case let wait as Wait:
                XCTAssertEqual(2.4, wait.duration)
                
            default:
                XCTFail("Unexpected item \(item)")
            }
            
        }
    }

    func testParse_author_example() throws {
        
        let kmlFile = try getSampleFile("author_example", type: "kml")

        let kml = try KMLParser.parse(file: kmlFile)
        
        let document = kml.findFirstFeatures(ofType: KMLDocument.self)!
        
        XCTAssertEqual("J. K. Rowling", document.author?.nameOrUriOrEmail.first)
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
        
        let document = kml.findFirstFeatures(ofType: KMLDocument.self)!
        let style = document.styleSelector.first as! KMLStyle
        let balloonStyle = style.balloonStyle
        
        XCTAssertEqual("#ffffffbb", balloonStyle?.bgColor?.hexRGBaColor)
        XCTAssertEqual("\n      <b><font color=\"#CC0000\" size=\"+3\">$[name]</font></b>\n      <br/><br/>\n      <font face=\"Courier\">$[description]</font>\n      <br/><br/>\n      Extra text that will appear in the description balloon\n      <br/><br/>\n      <!-- insert the to/from hyperlinks -->\n      $[geDirections]\n      ", balloonStyle?.text)
        
        
        
        let placemark = document.findFirstFeatures(ofType: KMLPlacemark.self)!
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
            .compactMap({ ($0 as? AnimatedUpdate)?.update })
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

        let document = kml.findFirstFeatures(ofType: KMLDocument.self)
        XCTAssertNotNil(document)
    }
    
    func testParse_embedded_video_sample() throws {
        
        let kmlFile = try getSampleFile("embedded_video_sample", type: "kml")

        let kml = try KMLParser.parse(file: kmlFile)
     
        let placemark = kml.findFirstFeatures(ofType: KMLPlacemark.self)!
        
        XCTAssert(placemark.featureDescription!.contains("application/x-shockwave-flash"))
        
    }
    
    func testParse_folder_example() throws {

        let kmlFile = try getSampleFile("folder_example", type: "kml")

        let kml = try KMLParser.parse(file: kmlFile)
        
        let folder = kml.findFirstFeatures(ofType: KMLFolder.self)!
        XCTAssertEqual(3, folder.count)
        XCTAssertEqual("Folder.kml", folder.name)
        XCTAssertEqual("A folder is a container that can hold multiple other objects", folder.featureDescription)
        XCTAssertTrue(folder.open)

    }
    
    
    func testParse_groundoverlay_example() throws {
        
        let kmlFile = try getSampleFile("groundoverlay_example", type: "kml")

        let kml = try KMLParser.parse(file: kmlFile)
        
        let groundOverlay = kml.findFirstFeatures(ofType: KMLGroundOverlay.self)!

        XCTAssertEqual("GroundOverlay.kml", groundOverlay.name)
        XCTAssertEqual("#7fffffff", groundOverlay.color?.hexRGBaColor)
        XCTAssertEqual(1, groundOverlay.drawOrder)
        
        let icon = groundOverlay.icon!
        XCTAssertEqual(URL(string: "http://www.google.com/intl/en/images/logo.gif"), icon.href)
        XCTAssertEqual(.onInterval, icon.refreshMode)
        XCTAssertEqual(86400, icon.refreshInterval)
        XCTAssertEqual(0.75, icon.viewBoundScale)
        
        let box = groundOverlay.latLonBox!
        XCTAssertEqual(37.83234, box.north)
        XCTAssertEqual(37.832122, box.south)
        XCTAssertEqual(-122.373033, box.east)
        XCTAssertEqual(-122.373724, box.west)
        XCTAssertEqual(45, box.rotation)

    }

    func testParse_iconstyle_example() throws {
        
        let kmlFile = try getSampleFile("iconstyle_example", type: "kml")

        let kml = try KMLParser.parse(file: kmlFile)
        
        let document = kml.findFirstFeatures(ofType: KMLDocument.self)!
        let style: KMLStyle = document.findStyle(withId: "randomColorIcon")!
        let iconStyle = style.iconStyle!
        
        XCTAssertEqual("#ff00ff00", iconStyle.color.hexRGBaColor)
        XCTAssertEqual(.random, iconStyle.colorMode)
        XCTAssertEqual(1.1, iconStyle.scale)
        
        let icon = iconStyle.icon!
        XCTAssertEqual(URL(string: "http://maps.google.com/mapfiles/kml/pal3/icon21.png"), icon.href)

        
    }
    
}
