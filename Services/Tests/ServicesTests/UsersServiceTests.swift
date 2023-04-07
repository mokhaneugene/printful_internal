//
//  UsersServiceTests.swift
//  ServicesTests
//
//  Created by Eugene Mokhan on 08/04/2023.
//

import XCTest
@testable import Services

class UsersServiceTest: TCPServiceTest {

    // MARK: - Constants

    private enum Constants {
        static let email: String = "mokhaneugene"
    }

    // MARK: - Private

    private lazy var usersService: UsersServiceProtocol = {
        let dependencies = UsersService.Dependencies(tcpService: tcpService)
        return UsersService(dependencies: dependencies)
    }()

    func testGetUserModels() {
        _ = usersService.getUserModels(for: Constants.email)
            .sink(
                receiveCompletion: { _ in
                    XCTAssert(false)
                },
                receiveValue: { userModels in
                    XCTAssert(!userModels.isEmpty)
                }
            )
    }
}
