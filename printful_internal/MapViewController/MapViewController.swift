//
//  MapViewController.swift
//  printful_internal
//
//  Created by Eugene Mokhan on 07/04/2023.
//

import UIKit

final class MapViewController: UIViewController {

    typealias Constants = MapResources.Constants.View

    // MARK: - Private

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
    }

    func setupViewModel() {
        viewModel?.onStateChange = { [weak self] state in
            guard let self = self else { return }

            switch state {
            case .onDataReady(let isDataReady):
                // TODO: - Add loading spinner
                break
            case .onError(let errorDescription):
                // TODO: - Add error view
                break
            }
        }
        viewModel?.launch()
    }
}
