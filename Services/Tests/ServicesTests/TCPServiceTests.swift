//
//  TCPServiceTest.swift
//  ServicesTests
//
//  Created by Eugene Mokhan on 07/04/2023.
//

import XCTest
@testable import Services

class TCPServiceTest: XCTestCase {

    // MARK: - Private

    private(set) var tcpService: TCPServiceProtocol = TCPService()

    // MARK: - Public methods

    func testAuthorizeRequest_valid_email() {
        let expectation = expectation(description: "Expecting response")
        let email = "mokhaneugene"

        tcpService.run(
            with: email,
            completion: { result in
                switch result {
                case .failure(_):
                    XCTFail("Should not return error")
                case .success(let userModels):
                    XCTAssertNotNil(userModels)
                    expectation.fulfill()
                }
            }
        )
        waitForExpectations(timeout: 5, handler: nil)
    }

    // TODO: - Should be fixed at the backEnd side
//    func testAuthorizeRequest_invalid_email() {
//        let expectation = expectation(description: "Expecting response")
//        let email = "mokhaneugene@gmail.com"
//
//        tcpService.run(
//            with: email,
//            completion: { result in
//                switch result {
//                case .failure(let error):
//                    XCTAssertNotNil(error)
//                    expectation.fulfill()
//                case .success(_):
//                    XCTFail("Should not succeed with an invalid email")
//                }
//            }
//        )
//        waitForExpectations(timeout: 5, handler: nil)
//    }
}
