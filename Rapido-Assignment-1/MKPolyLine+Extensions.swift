//
//  MKPolyLine+Extensions.swift
//  Rapido-Assignment-1
//
//  Created by Pranjal Agarwal on 12/09/24.
//

import MapKit

extension MKPolyline {
    func coordinates() -> [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: self.pointCount)
        self.getCoordinates(&coords, range: NSRange(location: 0, length: self.pointCount))
        return coords
    }
}
