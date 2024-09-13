//
//  Rapido_Assignment_1Tests.swift
//  Rapido-Assignment-1Tests
//
//  Created by Pranjal Agarwal on 11/09/24.
//

import XCTest
import MapKit
import CoreLocation
@testable import Rapido_Assignment_1

final class ViewModelTests: XCTestCase {
    
    var viewModel: ViewModel!
    var mockDelegate: MockMapViewDelegate!


    override func setUp() {
        super.setUp()
        viewModel = ViewModel()
        mockDelegate = MockMapViewDelegate()
        viewModel.delegate = mockDelegate
    }

    override func tearDown() {
        viewModel = nil
        mockDelegate = nil
        super.tearDown()
    }

    func testGetRoute() {
        let source = Mock.startLocationCoordinate
        let destination = Mock.destinationLocationCoordinate
        
        let expectation = XCTestExpectation(description: "Response should not be nil")
        viewModel.getRoute(from: source, to: destination)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
        XCTAssertNotNil(mockDelegate.lastRouteResponse, "Response should not be nil")
        XCTAssertNotNil(mockDelegate.lastRouteResponse?.polyline, "Polyline should not be nil")
        XCTAssertNil(mockDelegate.lastRouteResponse?.error, "Error should be nil")


    }

    func testGetRouteError() {
        let source = Mock.startLocationCoordinate
        let destination = Mock.startLocationCoordinate
        let expectation = XCTestExpectation(description: "Response should not be nil")
        viewModel.getRoute(from: source, to: destination)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        XCTAssertNotNil(mockDelegate.lastRouteResponse, "Route response should not be nil")
        XCTAssertNotNil(mockDelegate.lastRouteResponse?.error)
        XCTAssertNil(mockDelegate.lastRouteResponse?.polyline, "Polyline should be nil in case of error")
    }

    func testCalculateDistanceBetweenCoordinates() {
        let coordinate1 = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let coordinate2 = CLLocationCoordinate2D(latitude: 37.3382, longitude: -121.8863)
        let distance = viewModel.calculateDistanceBetweenCoordinates(from: coordinate1, to: coordinate2)
        XCTAssertEqual(distance, 67500, accuracy: 500)
    }

    func testStartSimulatingMovement() {
        viewModel.routeCoordinates = [
            CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            CLLocationCoordinate2D(latitude: 37.7750, longitude: -122.4195),
            CLLocationCoordinate2D(latitude: 37.7751, longitude: -122.4196)
        ]
        let expectation = XCTestExpectation(description: "Simulation steps occurred")
        viewModel.startSimulatingMovement()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
        XCTAssertTrue(mockDelegate.animateCoordinateCalled)
    }
}

class MockMapViewDelegate: MapViewDelegate {

    
    var lastRouteResponse: RouteViewModel?
    var regionUpdateCalled = false
    var animateCoordinateCalled = false

    func didGetRoute(response: Rapido_Assignment_1.RouteViewModel) {
        lastRouteResponse = response
    }

    func didUpdateRegion(region: MKCoordinateRegion) {
        regionUpdateCalled = true
    }

    func startAnimatingDriverPostion(coordinate: CLLocationCoordinate2D) {
        animateCoordinateCalled = true
    }
}
