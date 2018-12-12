//
//  LocationService.swift
//  DarkSky
//
//  Created by Yariv Nissim on 12/11/18.
//  Copyright © 2018 Yariv. All rights reserved.
//

import Foundation
import CoreLocation

enum LocationServiceError: Error {
    case locationManagerError(Error)
}

final class LocationService: NSObject {
    private let manager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()

    typealias CompletionType = (Result<CLLocation, LocationServiceError>) -> Void

    private var completion: CompletionType?

    // Create a block-based function to request a location instead of using a delegate.
    func requestLocation(completion: @escaping CompletionType) {
        self.completion = completion
        manager.requestLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // From the documentation - we're guaranteed to have at least one result and last one is most recent:
        // "This array always contains at least one object representing the current location. The most recent location update is at the end of the array."
        completion?(.success(locations.last!))
        completion = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion?(.failure(.locationManagerError(error)))
        completion = nil
    }
}
