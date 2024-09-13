//
//  DriverAnnotation.swift
//  Rapido-Assignment-1
//
//  Created by Pranjal Agarwal on 13/09/24.
//

import Foundation
import MapKit

final class ModifiedMKPointAnnotation: MKPointAnnotation, TypedAnnotation {
    var type: AnnotationType?
    init(type: AnnotationType) {
        self.type = type
    }
}
