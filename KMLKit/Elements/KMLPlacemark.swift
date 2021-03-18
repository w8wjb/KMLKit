//
//  Placemark.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

/**
 A Placemark is a Feature with associated Geometry. In Google Earth, a Placemark appears as a list item in the Places panel. A Placemark with a Point has an icon associated with it that marks a point on the Earth in the 3D viewer. (In the Google Earth 3D viewer, a Point Placemark is the only object you can click or roll over. Other Geometry objects do not have an icon in the 3D viewer. To give the user something to click in the 3D viewer, you would need to create a MultiGeometry object that contains both a Point and the other Geometry object.)
 */
open class KMLPlacemark: KMLFeature, KMLGeometryCollection {
    @objc open var geometry: KMLGeometry?
    
    open func add(geometry: KMLGeometry) {
        self.geometry = geometry
    }
}

#if os(macOS)
extension KMLPlacemark {

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addChild(to: element, child: geometry, in: doc)
    }
}
#endif
