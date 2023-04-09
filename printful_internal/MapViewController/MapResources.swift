//
//  MapResources.swift
//  printful_internal
//
//  Created by Eugene Mokhan on 07/04/2023.
//

import Foundation
import MapKit

struct MapResources {

    class Handlers {

    }

    enum State {
        case onDataReady(Bool)
        case onError(String)
        case onRegion(MKCoordinateRegion)
        case onUpdateAnnotation(UserAnnotation)
    }

    enum Constants {
        enum View {
            static let animationDuration: CFTimeInterval = 0.3
        }

        enum Mock {
            static let email: String = "mokhaneugene@gmail.com"
            static let rigaCenterLatitude: CLLocationDegrees = 56.9677
            static let rigaCenterLongitude: CLLocationDegrees = 24.1056
            static let latitudeDelta: CLLocationDegrees = 0.004
            static let longitudeDelta: CLLocationDegrees = 0.004
        }
    }
}
