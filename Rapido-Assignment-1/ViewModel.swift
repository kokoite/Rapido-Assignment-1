//
//  ViewModel.swift
//  Rapido-Assignment-1
//
//  Created by Pranjal Agarwal on 12/09/24.
//

import Foundation

import MapKit

class ViewModel {
    // Properties
    private var selectedRoute: MKRoute?
    private var routeCoordinates: [CLLocationCoordinate2D] = []
    private var currentCoordinateIndex = 0
    weak var delegate: MapViewDelegate?

    func getRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .automobile

        let direction = MKDirections(request: request)
        direction.calculate { response, error in
            guard let response = response, error == nil else {
                print("Error is \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            guard let route = response.routes.first else { return }
            self.selectedRoute = route
            self.routeCoordinates = route.polyline.coordinates()
            self.delegate?.didGetRoute(polyline: route.polyline)
        }
    }

    func startSimulatingMovement() {
        guard !routeCoordinates.isEmpty else { return }
        simulateMovementStep()
    }

    private func simulateMovementStep() {
        guard currentCoordinateIndex < routeCoordinates.count else { return }
        let endCoordinate = routeCoordinates[currentCoordinateIndex]
        self.delegate?.startAnimatingCoordinate(coordinate: endCoordinate)
        currentCoordinateIndex += 1

        Timer.scheduledTimer(withTimeInterval: Mock.driverLocationPoolTime, repeats: false) { [weak self] _ in
            self?.simulateMovementStep()
        }
    }
}

