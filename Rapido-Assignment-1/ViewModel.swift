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
    var routeCoordinates: [CLLocationCoordinate2D] = []
    private var currentCoordinateIndex = 1
    private var lastDriverLocationInRegion: CLLocationCoordinate2D? = nil
    weak var delegate: MapViewDelegate?
    private var shouldUpdateProgress = true
    private var isSimulating = false

    func viewWillDisappear() {
        shouldUpdateProgress = false
    }

    func viewWillAppear() {
        shouldUpdateProgress = true
    }

    func getRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        Task {
            do {
                let distance = calculateDistanceBetweenCoordinates(from: source, to: destination)
                if(distance <= 10) {
                    throw NSError(domain: "Source and destination are same", code: 10)
                }
                let sourcePlacemark = MKPlacemark(coordinate: source)
            let destinationPlacemark = MKPlacemark(coordinate: destination)
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: sourcePlacemark)
            request.destination = MKMapItem(placemark: destinationPlacemark)
            request.transportType = .automobile
            let direction = MKDirections(request: request)
                let response = try await direction.calculate()
                guard let route = response.routes.first, shouldUpdateProgress else { return }
                self.selectedRoute = route
                self.routeCoordinates = route.polyline.coordinates()
                DispatchQueue.main.async {
                    self.delegate?.didGetRoute(response: .init(error: nil, polyline: route.polyline))
                }
            } catch (let error) {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.delegate?.didGetRoute(response: .init(error: error, polyline: nil))
                }
            }
        }
    }

    func startSimulatingMovement() {
        guard !routeCoordinates.isEmpty && !isSimulating else { return }
        currentCoordinateIndex = 0
        isSimulating = true
        lastDriverLocationInRegion = routeCoordinates[0]
        simulateMovementStep()
    }

    private func simulateMovementStep() {
        guard currentCoordinateIndex < routeCoordinates.count && shouldUpdateProgress else {
            isSimulating = false
            return
        }
        let endCoordinate = routeCoordinates[currentCoordinateIndex]
        guard let lastDriverLocationInRegion else { return }
        let distance = calculateDistanceBetweenCoordinates(from: lastDriverLocationInRegion, to: endCoordinate)
        if(distance > Mock.minimumDistanceForRegion) {
            let region = MKCoordinateRegion(center: endCoordinate, latitudinalMeters: Mock.latitudeDistanceForRegion, longitudinalMeters: Mock.longitudeDistanceForRegion)
            self.lastDriverLocationInRegion = endCoordinate
            delegate?.didUpdateRegion(region: region)
        }
        delegate?.startAnimatingDriverPostion(coordinate: endCoordinate)
        currentCoordinateIndex += 1
        Timer.scheduledTimer(withTimeInterval: Mock.driverLocationPoolTime, repeats: false) { [weak self] _ in
            self?.simulateMovementStep()
        }
    }

    func calculateDistanceBetweenCoordinates(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D)-> Double  {
        let loc1 = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let loc2 = CLLocation(latitude: to.latitude, longitude: to.longitude)
        let distance = loc1.distance(from: loc2)
        return distance
    }
}


