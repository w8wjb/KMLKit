//
//  KMLDocument.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/28/21.
//

import Foundation


open class KMLDocument: KMLContainer {
    @objc open var schema: KMLSchema?
}

#if os(macOS)
extension KMLDocument {

//    class override var elementName: String { "Document" }

    override func toElement() -> XMLElement {
        let element = super.toElement()
        
        return element
    }
}
#endif
