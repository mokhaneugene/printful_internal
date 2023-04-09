//
//  MapViewController.swift
//  printful_internal
//
//  Created by Eugene Mokhan on 07/04/2023.
//

import UIKit
import MapKit
import SnapKit

final class MapViewController: UIViewController {

    typealias Constants = MapResources.Constants.View

    // MARK: - Private

    private let mapView = MKMapView()

    private var viewModel: MapViewModelling?

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupItems()
    }

    // MARK: - Configure

    func configure(with viewModel: MapViewModelling) {
        self.viewModel = viewModel
        setupViewModel()
    }
}

// MARK: - Private methods

private extension MapViewController {
    func setupItems() {
        view.backgroundColor = .white
        setupMapView()
    }

    func setupViewModel() {
        viewModel?.onStateChange = { [weak self] state in
            guard let self = self else { return }

            switch state {
            case .onDataReady(_):
                // TODO: - Add loading spinner
                break
            case .onError(let error):
                // TODO: - Add error view
                print("error: \(error)")
            case .onRegion(let region):
                self.mapView.setRegion(region, animated: true)
            case .onUpdateAnnotation(let annotation):
                self.updateAnnotation(with: annotation)
            }
        }
        viewModel?.launch()
    }

    func setupMapView() {
        view.addSubview(mapView)
        mapView.register(UserAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func updateAnnotation(with newAnnotation: UserAnnotation) {
        guard let annotations = mapView.annotations as? [UserAnnotation],
              let annotation = annotations.first(where: { $0.id == newAnnotation.id }),
              let annotationView = mapView.view(for: annotation) as? UserAnnotationView else {
            mapView.addAnnotation(newAnnotation)
            return
        }
        
        let newPosition = mapView.convert(newAnnotation.coordinate, toPointTo: mapView)
        UIView.animate(
            withDuration: Constants.animationDuration,
            animations: {
                annotationView.center = newPosition
            },
            completion: { _ in
                annotation.updateCoordinate(with: newAnnotation.coordinate)
                annotationView.updateItems()
            }
        )
    }
}
