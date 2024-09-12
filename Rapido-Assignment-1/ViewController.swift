//
//  ViewController.swift
//  Rapido-Assignment-1
//
//  Created by Pranjal Agarwal on 11/09/24.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewDelegate: AnyObject {
    func didGetRoute(polyline: MKPolyline)
    func startAnimatingCoordinate(coordinate: CLLocationCoordinate2D)
}

class ViewController: UIViewController {

    private var mapView: MKMapView!
    private var startButton: UIButton!

    private var mapViewModel: ViewModel!
    private var driverAnnotation: MKPointAnnotation!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let region = MKCoordinateRegion(center: Mock.startLocationCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        setupMapView()
        setupButton()
        addStartAnnotation()
        addDestinationAnnotation()
        addDriverAnnotation()
    }



    private func setupViewModel() {
        mapViewModel = ViewModel()
        mapViewModel.delegate = self
        mapViewModel.getRoute(from: Mock.startLocationCoordinate, to: Mock.destinationLocationCoordinate)
    }

    private func setupMapView() {
        let mapView = MKMapView()
        self.mapView = mapView
        mapView.delegate = self
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        mapView.setTranslateMask()
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
        button.setTranslateMask()
        button.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.4).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.bottomAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -10).isActive = true
        button.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20).isActive = true
    }

    @objc private func startButtonClicked() {
        mapViewModel.startSimulatingMovement()
    }

    private func addStartAnnotation() {
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

    private func addDriverAnnotation() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = Mock.startLocationCoordinate
        mapView.addAnnotation(annotation)
        driverAnnotation = annotation
    }

    private func animateDriverPosition(to coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 2.0) {
            self.driverAnnotation.coordinate = coordinate
            self.mapView.layoutIfNeeded()
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 6.0
            return renderer
        }
        return MKOverlayRenderer()
    }
}

extension ViewController: MapViewDelegate {
    
    func didGetRoute(polyline: MKPolyline) {
        mapView.addOverlay(polyline)
    }

    func startAnimatingCoordinate(coordinate: CLLocationCoordinate2D) {
        animateDriverPosition(to: coordinate)
    }
}
