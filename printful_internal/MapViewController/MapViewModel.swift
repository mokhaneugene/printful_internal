//
//  MapViewModel.swift
//  printful_internal
//
//  Created by Eugene Mokhan on 07/04/2023.
//

import Foundation
import Services
import Combine
import MapKit

protocol MapViewModelling {
    var onStateChange: ((MapResources.State) -> Void)? { get set }

    func launch()
}

final class MapViewModel: MapViewModelling {

    typealias Constants = MapResources.Constants.Mock

    var onStateChange: ((MapResources.State) -> Void)?

    // MARK: - Private

    private let handlers: MapResources.Handlers
    private let services: ServicesContextProtocol

    private var userModels: [UserModel] = []
    private var cancellables: [AnyCancellable] = []

    // MARK: - Init

    init(handlers: MapResources.Handlers, services: ServicesContextProtocol) {
        self.handlers = handlers
        self.services = services
    }

    deinit {
        cancellables.forEach({ $0.cancel() })
        cancellables = []
    }

    // MARK: - Public methods

    func launch() {
        onStateChange?(.onDataReady(false))
        setupModels()
    }
}

// MARK: - Private methods

private extension MapViewModel {
    func setupModels() {
        setupUserModels()
        updateUserModels()
        updateRegion()
    }

    func setupUserModels() {
        let cancellable = services.usersService.getUserModels(for: Constants.email)
            .sink(
                receiveCompletion: { [weak self] errorCompletion in
                    switch errorCompletion {
                    case .finished:
                        return
                    case .failure(let error):
                        self?.onStateChange?(.onError(error.localizedDescription))
                    }
                },
                receiveValue: { [weak self] userModels in
                    self?.userModels = userModels
                    DispatchQueue.main.async { [weak self] in
                        self?.updateRegion()
                        self?.setupAnnotations()
                    }
                }
            )
        cancellables.append(cancellable)
    }

    func updateUserModels() {
        let cancellable = services.usersService.getUsersUpdates()
            .sink(
                receiveCompletion: { [weak self] errorCompletion in
                    switch errorCompletion {
                    case .finished:
                        return
                    case .failure(let error):
                        self?.onStateChange?(.onError(error.localizedDescription))
                    }
                },
                receiveValue: { [weak self] userModels in
                    DispatchQueue.main.async { [weak self] in
                        self?.updateAnnotations(with: userModels)
                    }
                }
            )
        cancellables.append(cancellable)
    }

    func updateRegion() {
        let latitudes = userModels.compactMap({ Double($0.latitude) }).sorted()
        let longitudes = userModels.compactMap({ Double($0.longitude) }).sorted()

        var centerLatitude = Constants.rigaCenterLatitude
        var latitudeDelta = Constants.latitudeDelta
        if let lowestLatitude = latitudes.first, let highestLatitude = latitudes.last {
            centerLatitude = (lowestLatitude + highestLatitude) / 2.0
            latitudeDelta += abs(abs(highestLatitude) - abs(lowestLatitude))
        }

        var centerLongitude = Constants.rigaCenterLongitude
        var longitudeDelta = Constants.longitudeDelta
        if let lowestLongitude = longitudes.first, let highestLongitude = longitudes.last {
            centerLongitude = (lowestLongitude + highestLongitude) / 2.0
            longitudeDelta += abs(abs(highestLongitude) - abs(lowestLongitude))
        }

        let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let region = MKCoordinateRegion(center: center, span: span)
        onStateChange?(.onRegion(region))
    }

    func setupAnnotations() {
        for userModel in userModels {
            guard let latitude = Double(userModel.latitude), let longitude = Double(userModel.longitude) else { continue }

            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = UserAnnotation(id: userModel.id,
                                            coordinate: coordinate,
                                            titleText: userModel.name,
                                            imageLink: userModel.image)
            onStateChange?(.onUpdateAnnotation(annotation))
        }
    }

    func updateAnnotations(with userModels: [UserModel]) {
        for userModel in userModels {
            guard let latitude = Double(userModel.latitude), let longitude = Double(userModel.longitude) else { continue }

            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = UserAnnotation(id: userModel.id, coordinate: coordinate)
            onStateChange?(.onUpdateAnnotation(annotation))
        }
    }
}
