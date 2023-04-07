//
//  UserModel.swift
//  Services
//
//  Created by Eugene Mokhan on 07/04/2023.
//

import Foundation

public struct UserModel {
    public let id: String
    public let name: String?
    public let image: String?
    public var latitude: String
    public var longitude: String

    public init(id: String, name: String? = nil, image: String? = nil, latitude: String, longitude: String) {
        self.id = id
        self.name = name
        self.image = image
        self.latitude = latitude
        self.longitude = longitude
    }
}
