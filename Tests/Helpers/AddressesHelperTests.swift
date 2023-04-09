//
//  AddressesHelperTests.swift
//  Tests
//
//  Created by Eugene Mokhan on 10/04/2023.
//

import XCTest
import CoreLocation

final class AddressesHelperTests: XCTestCase {

    func testAddress() {
        let expectation = expectation(description: "Expecting valid address")
        let rigaLocation = CLLocationCoordinate2D(latitude: 56.9677, longitude: 24.1056)
        let rigaAddress: String = "Pētersalas iela 1B"

        AddressesHelper.getAddressFrom(coordinate: rigaLocation) { result in
            switch result {
            case .success(let address):
                XCTAssertEqual(address, rigaAddress)
                expectation.fulfill()
            case .failure(_):
                XCTFail("Should not return error")
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}
