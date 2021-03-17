//
//  KMLDocument.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/28/21.
//

import Foundation

/**
 A Document is a container for features and styles. This element is required if your KML file uses shared styles. It is recommended that you use shared styles, which require the following steps:

 1. Define all Styles in a Document. Assign a unique **ID** to each Style.
 2. Within a given Feature or StyleMap, reference the Style's ID using a &lt;styleUrl&gt; element.
 
 Note that shared styles are not inherited by the Features in the Document.

 Each Feature must explicitly reference the styles it uses in a &lt;styleUrl&gt; element. For a Style that applies to a Document (such as ListStyle), the Document itself must explicitly reference the &lt;styleUrl&gt;.
 
 - Warning: Do not put shared styles within a Folder.
 */
open class KMLDocument: KMLContainer {
    @objc open var schema: KMLSchema?
}

#if os(macOS)
extension KMLDocument {

    override func toElement(in doc: XMLDocument) -> XMLElement {
        let element = super.toElement(in: doc)
        addChild(to: element, child: schema, in: doc)
        return element
    }
}
#endif
