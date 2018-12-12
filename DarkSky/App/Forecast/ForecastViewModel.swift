//
//  ForecastViewModel.swift
//  DarkSky
//
//  Created by Yariv Nissim on 12/11/18.
//  Copyright © 2018 Yariv. All rights reserved.
//

import UIKit
import CoreLocation

final class ForecastViewModel: NSObject {
    private let darkSky: DarkSkyService
    private let locationService: LocationServiceProtocol
    private let cellIdentifier: String

    init(darkSky: DarkSkyService, locationService: LocationServiceProtocol, cellIdentifier: String) {
        self.darkSky = darkSky
        self.locationService = locationService
        self.cellIdentifier = cellIdentifier
    }

    // The view controller should subscribe to this
    var stateChanged: ((State) -> Void)?

    private var state: State = .empty {
        didSet {
            stateChanged?(state)
        }
    }

    // Use State to store relevant data
    enum State {
        case forecast(DarkSkyForecast)
        case location(CLLocationCoordinate2D)
        case loading
        case empty
        case error(Error)

        func getForecast() -> DarkSkyForecast? {
            guard case let .forecast(forecast) = self else {
                return nil
            }
            return forecast
        }
    }

    func findCurrentLocation() {
        locationService.requestLocation { result in
            do {
                self.state = .location(try result.get().coordinate)
            } catch {
                self.state = .error(error)
            }
        }
    }

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    func loadWeatherForecast(for location: CLLocationCoordinate2D) {
        darkSky.getForecast(location: location) { result in
            do {
                let forecast = try result.get()
                // Set the time zone on the formatter when fetching new weather data
                self.dayFormatter.timeZone = TimeZone(identifier: forecast.timezone)
                self.state = .forecast(forecast)
            } catch {
                self.state = .error(error)
            }
        }
    }
}

extension ForecastViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.getForecast()?.daily.data.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        guard let forecast = state.getForecast() else {
            return cell
        }
        configureCell(cell, with: forecast.daily.data[indexPath.row])
        return cell
    }

    func configureCell(_ cell: UITableViewCell, with daily: DarkSkyDaily) {
        cell.textLabel?.text = dayFormatter.string(from: daily.time)
        cell.imageView?.image = UIImage(imageLiteralResourceName: daily.icon)
    }
}
