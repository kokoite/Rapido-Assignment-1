//
//  ViewController.swift
//  Rapido-Assignment-1
//
//  Created by Pranjal Agarwal on 11/09/24.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {


    private var startButton: UIButton!
    private var mapView: MKMapView!
    private var mapAndButtonContainer: UIStackView!
    private var locationManager: CLLocationManager?


    private var currentStep = 0
    private var timer: Timer?



    private var driverCurrentLocation: CLLocation?
    private var destinationLocation: CLLocation?
    private var routeOverlay: MKPolyline?

    private var routeCoordinates: [CLLocationCoordinate2D] = []
    private var currentCoordinateIndex = 0



    @objc private func startButtonClicked() {
        print("start button clicked")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }


    private func setup() {
        view.backgroundColor = .white
        setupLocationManager()
        setupMapView()
        setupButton()
        addStartAnnotation()
        addDestinationAnnotation()
        getRoute()
    }

    private func requestAndHandleLocationPermission() {
        guard let locationManager else { return}
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("permission granted")
            handleLocationPermissionGranted()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            handleLocationPermissionDenied()
            print("Permission denied")
        @unknown default:
            print("unknown error occured")
        }
    }

    private func handleLocationPermissionDenied() {
        // TODO :- Show a alert box for permission
    }

    private func handleLocationPermissionGranted() {
        guard let locationManager else { return }
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()

        let region = MKCoordinateRegion(center: Mock.startLocationCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }


    private func setupLocationManager() {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager = locationManager
    }

    private func setupMapView() {
        let mapView = MKMapView()
        self.mapView = mapView
        mapView.delegate = self
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        mapView.setTranslatesMask()
        mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mapView.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.8).isActive = true
    }

    private func setupButton() {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        let button = UIButton(configuration: config)
        view.addSubview(button)
        button.setTitle("Start Driver", for: .normal)
        startButton = button
        button.addTarget(self, action: #selector(startButtonClicked), for: .touchUpInside)
        button.setTranslatesMask()
        button.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.4).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.bottomAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -10).isActive = true
        button.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20).isActive = true
    }

    private func addStartAnnotation() {
        guard let locationManager, let location = locationManager.location else { return }
        let annotation = MKPointAnnotation()
        annotation.coordinate = Mock.startLocationCoordinate
        annotation.title = "Start"
        mapView.addAnnotation(annotation)
    }

    private func addDestinationAnnotation() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = Mock.destinationLocationCoordinate
        annotation.title = "Destination"
        mapView.addAnnotation(annotation)
    }

    private func getRoute() {
        let source = Mock.startLocationCoordinate
        let destination = Mock.destinationLocationCoordinate
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .automobile

        let direction = MKDirections(request: request)

        direction.calculate { response, error in
            guard let response, error == nil else {
                print("Error is \(error?.localizedDescription)")
                return
            }

            guard let route = response.routes.first else { return }
            self.mapView.addOverlay(route.polyline)
            print("Response is \(response)")
        }
    }
}


extension ViewController: MKMapViewDelegate {


    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 4.0
            return renderer
        }
        return MKOverlayRenderer()
    }
}

extension ViewController: CLLocationManagerDelegate {

    private func updateDriverPosition() {

    }

    private func updateRegion() {
        guard let driverCurrentLocation else { return }
        print(driverCurrentLocation)
        let region = MKCoordinateRegion(center: driverCurrentLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !locations.isEmpty else { return }

        driverCurrentLocation = locations.last
        updateDriverPosition()
        updateRegion()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO :- Do error handling
        print("Error is \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestAndHandleLocationPermission()
    }
}
