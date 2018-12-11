//
//  DarkSkyAPI.swift
//  DarkSky
//
//  Created by Yariv Nissim on 12/10/18.
//  Copyright © 2018 Yariv. All rights reserved.
//

import Foundation
import CoreLocation

enum DarkSkyError: Error, CustomStringConvertible {
    case darkSkyUnavailable
    case invalidURL
    case badResponse
    case unknown(Error)

    var description: String {
        switch self {
        case .darkSkyUnavailable: return "DarkSky service is temporarily unavailable."
        case .invalidURL: return "Could not parse DarkSky URL."
        case .badResponse: return "Could not decode data from DarkSky service."
        case .unknown: return "Unknown error occurred with DarkSky service."
        }
    }
}

final class DarkSkyService {
    private let apiKey: String
    private let baseURL = "api.darksky.net"

    typealias CompletionType = (Result<DarkSkyForecast, DarkSkyError>) -> Void

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    private func generateURL(location: CLLocationCoordinate2D, time: Date? = nil) -> URL? {
        var components = URLComponents()
        components.host = baseURL
        components.scheme = "https"
        // request only what's necessary to reduce response size
        components.queryItems = [URLQueryItem(name: "exclude", value: "[currently, minutely, hourly, alerts, flags]")]

        // send key and location in path
        components.path += "/\(apiKey)"
        components.path += "/\(location.latitude),\(location.longitude)"

        // for time machine requests
        if let time = time {
            components.path += "/\(time.timeIntervalSince1970)"
        }

        return components.url
    }

    func getForecast(location: CLLocationCoordinate2D, time: Date? = nil, completion: @escaping CompletionType) {
        guard let url = generateURL(location: location, time: time) else {
            completion(.failure(.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                // error is guaranteed in documentation to be non-nil when data is empty
                completion(.failure(.unknown(error!)))
                return
            }

            do {
                let forecast = try DarkSkyForecast(data: data)
                completion(.success(forecast))
            } catch {
                completion(.failure(.unknown(error)))
            }
        }.resume()
    }
}

extension DarkSkyForecast {
    /// Decode from data using JSONDecoder
    init(data: Data) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        let forecast = try decoder.decode(DarkSkyForecast.self, from: data)
        self = forecast
    }
}
