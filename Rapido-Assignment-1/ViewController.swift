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
    func didGetRoute(response: RouteViewModel)
    func startAnimatingDriverPostion(coordinate: CLLocationCoordinate2D)
    func didUpdateRegion(region: MKCoordinateRegion)
}

class ViewController: UIViewController {

    private var mapView: MKMapView!
    private var startButton: UIButton!
    private var mapViewModel: ViewModel!
    private var driverAnnotation: MKPointAnnotation!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let region = MKCoordinateRegion(center: Mock.startLocationCoordinate, latitudinalMeters: Mock.latitudeDistanceForRegion, longitudinalMeters: Mock.longitudeDistanceForRegion)
        self.mapView.setRegion(region, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapViewModel.delegate = self
        mapViewModel.viewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        mapViewModel.viewWillDisappear()
        mapViewModel.delegate = nil
    }

    @objc private func startButtonClicked() {
        let region = MKCoordinateRegion(center: Mock.startLocationCoordinate, latitudinalMeters: Mock.latitudeDistanceForRegion, longitudinalMeters: Mock.longitudeDistanceForRegion)
        self.mapView.setRegion(region, animated: true)
        mapViewModel.startSimulatingMovement()
    }

    private func setupUI() {
        view.backgroundColor = .white
        setupMapView()
        setupButton()
        let _ = createModifiedAnnotation(type: .source, coordinate: Mock.startLocationCoordinate)
        let _ = createModifiedAnnotation(type: .destination, coordinate: Mock.destinationLocationCoordinate)
        driverAnnotation = createModifiedAnnotation(type: .driver, coordinate: Mock.startLocationCoordinate)
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

    private func createModifiedAnnotation(type: AnnotationType, coordinate: CLLocationCoordinate2D) -> MKPointAnnotation {
        let annotation = ModifiedMKPointAnnotation(type: type)
        annotation.coordinate = coordinate
        annotation.title = type.rawValue
        mapView.addAnnotation(annotation)
        return annotation
    }

    private func animateDriverPosition(to coordinate: CLLocationCoordinate2D) {
        /*
         For animating polyline along with driver position. I believe it will be very
         complex in simulation. Here is what i think we can do it (I was not able to try it due to some time constraint) for each path we know start and end coordinate
         if we break the distance between both coordinate into lets say 1000 steps (this is hypothetical).
        we can get intermediate coordinates (count of intermediate coordinates will be equal to number of steps) with the help of interpolation between start and end coordinate.
         Instead of animating driver coordinate directly fromr start and end, we will update the coordinates based on intermediate coordinate. Due to very high number of steps, it would seem like driver is moving (it should feel like we are animating)
         and we will also have current coordinate of the driver. which will help us redrawing polyline with driver position updated

         For real life scenario i think it would be easy to update polyline as the driver is moving because we already have the coordinate where driver is currently at
         */
        UIView.animate(withDuration: Mock.driverAnimationTime) {
            self.driverAnnotation.coordinate = coordinate
            self.view.layoutIfNeeded()
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

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard let annotation = annotation as? TypedAnnotation, let type = annotation.type else { return nil }
        var annotationView: MKAnnotationView? = nil

        switch type {
        case .driver:
            let view = MKAnnotationView()
            let image = UIImage(systemName: "car")
            view.image = image
            annotationView = view

        case .source:
            let view = MKAnnotationView()
            let image = UIImage(systemName: "s.circle")
            view.image = image
            annotationView = view

        case .destination:
            let view = MKAnnotationView()
            let image = UIImage(systemName: "d.circle")
            view.image = image
            annotationView = view
        }
        return annotationView
    }
}

extension ViewController: MapViewDelegate {

    // MARK :- Used for handling error while fetching route from source and destination
    private func handleError(error: Error?) {
        guard let error else { return }
        let alert = UIAlertController(title: "Something went wrong", message: "\(error.localizedDescription)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.mapViewModel.getRoute(from: Mock.startLocationCoordinate, to: Mock.destinationLocationCoordinate)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    // MARK :- Triggered when we got response from viewmodel for finding route
    func didGetRoute(response: RouteViewModel) {
        guard let polyline = response.polyline, response.error == nil else {
            handleError(error: response.error)
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.mapView.addOverlay(polyline)
        }
    }

    // MARK :- Triggered for updating driver coordinate
    func startAnimatingDriverPostion(coordinate: CLLocationCoordinate2D) {
        DispatchQueue.main.async { [weak self] in
            self?.animateDriverPosition(to: coordinate)
        }
    }

    // MARK :- Triggered when driver goes out of region with respect to its initial position in a previous region. Used to update the region
    func didUpdateRegion(region: MKCoordinateRegion) {
        DispatchQueue.main.async { [weak self] in
            self?.mapView.setRegion(region, animated: true)
        }
    }
}
