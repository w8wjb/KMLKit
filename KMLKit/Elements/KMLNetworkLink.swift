//
//  KMLNetworkLink.swift
//  KMLKit
//
//  Created by Weston Bustraan on 3/2/21.
//

import Foundation

/**
 References a KML file or KMZ archive on a local or remote network. Use the &lt;Link&gt; element to specify the location of the KML file. Within that element, you can define the refresh options for updating the file, based on time and camera change. NetworkLinks can be used in combination with Regions to handle very large datasets efficiently.
 */
open class KMLNetworkLink: KMLFeature {
    /**
     A value of 0 leaves the visibility of features within the control of the Google Earth user. Set the value to 1 to reset the visibility of features each time the NetworkLink is refreshed. For example, suppose a Placemark within the linked KML file has &lt;visibility&gt; set to 1 and the NetworkLink has &lt;refreshVisibility&gt; set to 1. When the file is first loaded into Google Earth, the user can clear the check box next to the item to turn off display in the 3D viewer. However, when the NetworkLink is refreshed, the Placemark will be made visible again, since its original visibility state was TRUE.
     */
    @objc open var refreshVisibility = false
    
    /**
     A value of 1 causes Google Earth to fly to the view of the LookAt or Camera in the NetworkLinkControl (if it exists). If the NetworkLinkControl does not contain an AbstractView element, Google Earth flies to the LookAt or Camera element in the Feature child within the &lt;kml&gt; element in the refreshed file. If the &lt;kml&gt; element does not have a LookAt or Camera specified, the view is unchanged. For example, Google Earth would fly to the &lt;LookAt&gt; view of the parent Document, not the &lt;LookAt&gt; of the Placemarks contained within the Document.
     */
    @objc open var flyToView = false
}

#if os(macOS)
extension KMLNetworkLink {

    override func toElement(in doc: XMLDocument) -> XMLElement {
        let element = super.toElement(in: doc)
        addSimpleChild(to: element, withName: "refreshVisibility", value: refreshVisibility, default: false)
        addSimpleChild(to: element, withName: "flyToView", value: flyToView, default: false)
        return element
    }
}
#endif
