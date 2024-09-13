//
//  MockData.swift
//  Rapido-Assignment-1
//
//  Created by Pranjal Agarwal on 12/09/24.
//

import Foundation
import CoreLocation

struct Mock {

    static var driverLocationPoolTime: Double = 1
    static var driverAnimationTime: Double = 2
    static var minimumDistanceForRegion: Double = 300
    static var latitudeDistanceForRegion: Double = 1000
    static var longitudeDistanceForRegion: Double = 1000
    static var startLocationCoordinate: CLLocationCoordinate2D = .init(latitude: +26.89080147, longitude: +75.72166256)
    static var destinationLocationCoordinate: CLLocationCoordinate2D = .init(latitude: 26.916648864746097, longitude: 75.73639297485352)
}
