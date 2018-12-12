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
    case locationAccessDenied
    case locationManagerError(Error)
}

protocol LocationServiceProtocol {
    typealias CompletionType = (Result<CLLocation, LocationServiceError>) -> Void
    func requestLocation(completion: @escaping CompletionType)
}

final class LocationService: NSObject, LocationServiceProtocol {
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
    }

    private var completion: CompletionType?

    // Create a block-based function to request a location instead of using a delegate.
    func requestLocation(completion: @escaping CompletionType) {
        self.completion = completion

        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            // Happy path - user already granted access
            manager.requestLocation()
        case .notDetermined:
            // Need to request authorization before requesting location
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // No access to location, nothing to do here
            completion(.failure(.locationAccessDenied))
            self.completion = nil
        }
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

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // If a completion closure is available then it's waiting for a location update,
        // Otherwise there's no need to handle an auhorization change.
        guard let completion = completion else { return }

        // Call this method again to handle the new authorization status
        requestLocation(completion: completion)
    }
}
