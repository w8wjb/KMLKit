//
//  Region.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import MapKit

/**
 A region contains a bounding box (&lt;LatLonAltBox&gt;) that describes an area of interest defined by geographic coordinates and altitudes. In addition, a Region contains an LOD (level of detail) extent (&lt;Lod&gt;) that defines a validity range of the associated Region in terms of projected screen size. A Region is said to be "active" when the bounding box is within the user's view and the LOD requirements are met. Objects associated with a Region are drawn only when the Region is active. When the &lt;viewRefreshMode&gt; is **onRegion**, the Link or Icon is loaded only when the Region is active. See the "Topics in KML" page on [Regions](https://developers.google.com/kml/documentation/regions) for more details. In a Container or NetworkLink hierarchy, this calculation uses the Region that is the closest ancestor in the hierarchy.
 */
open class KMLRegion: KMLObject {

    /** A bounding box that describes an area of interest defined by geographic coordinates and altitudes. */
    @objc open var extent: KMLAbstractExtent?
    @objc open var lod: KMLLevelOfDetail?
    @objc open var metadata: [AnyObject] = []

}

#if os(macOS)
extension KMLRegion {

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addChild(to: element, child: extent, in: doc)
        addChild(to: element, child: lod, in: doc)
    }
}
#endif
