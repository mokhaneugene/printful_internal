//
//  ServicesContext.swift
//  Services
//
//  Created by Eugene Mokhan on 07/04/2023.
//

import Foundation

public typealias ServicesContextProtocol =
TCPServiceHolder &
UsersServiceHolder

public struct ServicesContext: ServicesContextProtocol {

    public let tcpService: TCPServiceProtocol
    public let usersService: UsersServiceProtocol

    // MARK: - Init

    public init() {
        tcpService = TCPService()

        let usersServiceDependency = UsersService.Dependencies(tcpService: tcpService)
        usersService = UsersService(dependencies: usersServiceDependency)
    }
}
