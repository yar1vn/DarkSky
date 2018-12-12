//
//  DarkSkyService.swift
//  DarkSkyTests
//
//  Created by Yariv Nissim on 12/11/18.
//  Copyright © 2018 Yariv. All rights reserved.
//

import XCTest
import CoreLocation
@testable import DarkSky

class DarkSkyServiceTests: XCTestCase {
    func testGenerateURLForecast() {
        let darkSky = DarkSkyService(apiKey: "12345")
        let url = darkSky.generateURL(location: CLLocationCoordinate2D(latitude: 100, longitude: 200))

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString.removingPercentEncoding, "https://api.darksky.net/forecast/12345/100,200?exclude=[currently, minutely, hourly, alerts, flags]")
    }

    func testGenerateURLTimeMachine() {
        let darkSky = DarkSkyService(apiKey: "12345")
        let url = darkSky.generateURL(location: CLLocationCoordinate2D(latitude: 100, longitude: 200),
                                      time: Date(timeIntervalSince1970: 567890))

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString.removingPercentEncoding, "https://api.darksky.net/forecast/12345/100,200/567890?exclude=[currently, minutely, hourly, alerts, flags]")
    }
}
