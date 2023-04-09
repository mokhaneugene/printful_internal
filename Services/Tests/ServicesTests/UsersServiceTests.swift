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
        let expectation = expectation(description: "Expecting userModels")

        let cancelable = usersService.getUserModels(for: Constants.email)
            .sink(
                receiveCompletion: { _ in
                    XCTFail("Should not return error")
                },
                receiveValue: { userModels in
                    XCTAssert(!userModels.isEmpty)
                    expectation.fulfill()
                }
            )
        waitForExpectations(timeout: 5, handler: nil)
    }
}
