//
//  MapViewModel.swift
//  printful_internal
//
//  Created by Eugene Mokhan on 07/04/2023.
//

import Foundation
import Services
import Combine

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
    }

    func setupUserModels() {
        let cancellable = services.usersService.getUserModels(for: Constants.email)
            .sink(
                receiveCompletion: { _ in
                    // TODO: - Show error view
                },
                receiveValue: { [weak self] userModels in
                    self?.userModels = userModels
                    print("====")
                    print("userModels: \(userModels)")
                }
            )
        cancellables.append(cancellable)
    }

    func updateUserModels() {
        let cancellable = services.usersService.getUsersUpdates()
            .sink(
                receiveCompletion: { _ in
                    // TODO: - Show error view
                },
                receiveValue: { [weak self] userModels in
                    print("====")
                    print("updates: \(userModels)")
                }
            )
        cancellables.append(cancellable)
    }
}
