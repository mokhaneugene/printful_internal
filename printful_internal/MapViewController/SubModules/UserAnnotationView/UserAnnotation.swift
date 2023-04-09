//
//  UserAnnotation.swift
//  printful_internal
//
//  Created by Eugene Mokhan on 08/04/2023.
//

import Foundation
import MapKit

class UserAnnotation: NSObject, MKAnnotation {

    private(set) var id: String
    @objc private(set) dynamic var coordinate: CLLocationCoordinate2D
    private(set) var titleText: String?
    private(set) var imageLink: String?

    // MARK: - Init

    init(id: String,
         coordinate: CLLocationCoordinate2D,
         titleText: String? = nil,
         imageLink: String? = nil) {
        self.id = id
        self.coordinate = coordinate
        self.titleText = titleText
        self.imageLink = imageLink
        super.init()
    }

    // MARK: - Public methods

    func updateCoordinate(with coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
