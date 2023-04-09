//
//  AddressesHelper.swift
//  printful_internal
//
//  Created by Eugene Mokhan on 09/04/2023.
//

import Foundation
import CoreLocation

final class AddressesHelper {

    static func getAddressFrom(coordinate: CLLocationCoordinate2D, _ completion: @escaping (Result<String, Error>) -> Void) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                completion(.failure(error))
            }

            let streetName = placemarks?.first?.thoroughfare ?? ""
            let streetNumber = placemarks?.first?.subThoroughfare ?? ""

            let address = streetName + " " + streetNumber
            completion(.success(address))
        }
    }
}
