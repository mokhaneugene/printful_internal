//
//  TCPServiceTest.swift
//  ServicesTests
//
//  Created by Eugene Mokhan on 07/04/2023.
//

import XCTest
@testable import Services

final class TCPServiceTest: XCTestCase {

    // MARK: - Constants

    private enum Constants {
        static let email: String = "mokhaneugene"
    }

    // MARK: - Private

    private let tcpService = TCPService()

    // MARK: - Public methods

    func testAuthorizeRequest() {
        tcpService.run(
            with: Constants.email,
            completion: { result in
                switch result {
                case .failure(_):
                    XCTAssert(false)
                case .success(_):
                    XCTAssert(true)
                }
            }
        )
    }
}
