//
//  Lod.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation

/**
 Lod is an abbreviation for Level of Detail. &lt;Lod&gt; describes the size of the projected region on the screen that is required in order for the region to be considered "active." Also specifies the size of the pixel ramp used for fading in (from transparent to opaque) and fading out (from opaque to transparent).
 */
open class KMLLevelOfDetail: KMLObject {

    /**
     Defines a square in screen space, with sides of the specified value in pixels. For example, 128 defines a square of 128 x 128 pixels. The region's bounding box must be larger than this square (and smaller than the `maxLodPixels` square) in order for the Region to be active.

     More details are available in the [Working with Regions](https://developers.google.com/kml/documentation/regions) chapter of the Developer's Guide, as well as the Google Earth Outreach documentation's [Avoiding Overload with Regions](https://www.google.com/earth/outreach/tutorials/region.html) tutorial.
     */
    @objc open var minLodPixels: Double = 0.0
    /** Measurement in screen pixels that represents the maximum limit of the visibility range for a given Region. A value of −1, the default, indicates "active to infinite size." */
    @objc open var maxLodPixels: Double = -1.0
    /** Distance over which the geometry fades, from fully opaque to fully transparent. This ramp value, expressed in screen pixels, is applied at the minimum end of the LOD (visibility) limits. */
    @objc open var minFadeExtent: Double = 0.0
    /** Distance over which the geometry fades, from fully transparent to fully opaque. This ramp value, expressed in screen pixels, is applied at the maximum end of the LOD (visibility) limits. */
    @objc open var maxFadeExtent: Double = 0.0
    
}

#if os(macOS)
extension KMLLevelOfDetail {

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "minLodPixels", value: minLodPixels, default: 0.0)
        addSimpleChild(to: element, withName: "maxLodPixels", value: maxLodPixels, default: -1.0)
        addSimpleChild(to: element, withName: "minFadeExtent", value: minFadeExtent, default: 0.0)
        addSimpleChild(to: element, withName: "maxFadeExtent", value: maxFadeExtent, default: 0.0)
    }

}
#endif
