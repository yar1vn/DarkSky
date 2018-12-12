//
//  LocationServiceTests.swift
//  DarkSkyTests
//
//  Created by Yariv Nissim on 12/11/18.
//  Copyright © 2018 Yariv. All rights reserved.
//

import XCTest
import CoreLocation
@testable import DarkSky

// Another approach would be to create a protocol
final class MockLocationService: LocationServiceProtocol {
    private let coordinate: CLLocationCoordinate2D?

    // Provide a coordinate to return a successful response when calling requestLocation.
    // Otherwise fail with locationAccessDenied
    init(coordinate: CLLocationCoordinate2D? = nil) {
        self.coordinate = coordinate
    }

    func requestLocation(completion: @escaping LocationService.CompletionType) {
        guard let coordinate = coordinate else {
            completion(.failure(.locationAccessDenied))
            return
        }
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        completion(.success(location))
    }
}

class LocationServiceTests: XCTestCase {
    var locationService: LocationServiceProtocol!

    override func setUp() {
        locationService = nil
    }

    func testRequestLocation() {
        locationService = MockLocationService(coordinate: CLLocationCoordinate2D(latitude: 100, longitude: 200))

        let expectation = XCTestExpectation(description: "Find current location")

        locationService.requestLocation { result in
            // FIXME: There's something weird happening with the throwing call.
            //  Xcode won't build unless this is contained in do-catch but
            //  it doesn't really throw because the assert handles the error.
            do {
                XCTAssertNoThrow(try result.get())
                expectation.fulfill()
            } catch {}
        }
        wait(for: [expectation], timeout: 15)
    }

    func testRequestLocationNoAuthorization() {
        locationService = MockLocationService()

        let expectation = XCTestExpectation(description: "Find current location")

        locationService.requestLocation { result in
            do {
                XCTAssertThrowsError(try result.get())
                expectation.fulfill()
            } catch {}
        }
        wait(for: [expectation], timeout: 15)
    }
}
