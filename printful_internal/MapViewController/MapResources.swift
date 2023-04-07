//
//  MapResources.swift
//  printful_internal
//
//  Created by Eugene Mokhan on 07/04/2023.
//

import Foundation

struct MapResources {

    class Handlers {

    }

    enum State {
        case onDataReady(Bool)
        case onError(String?)
    }

    enum Constants {
        enum View {

        }

        enum Mock {
            static let email: String = "mokhaneugene"
        }
    }
}
