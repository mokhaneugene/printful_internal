//
//  MapFactory.swift
//  printful_internal
//
//  Created by Eugene Mokhan on 07/04/2023.
//

import UIKit
import Services

final class MapFactory {

    func createController(handlers: MapResources.Handlers, services: ServicesContextProtocol) -> UIViewController {
        let viewModel = MapViewModel(handlers: handlers, services: services)
        let viewController = MapViewController()

        viewController.configure(with: viewModel)

        return viewController
    }
}
