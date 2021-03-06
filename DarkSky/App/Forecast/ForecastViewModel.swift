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

    // The view controller should subscribe to this.
    // this could be upgraded with Rx in the future.
    var stateChanged: ((State) -> Void)?

    private var state: State = .empty {
        didSet {
            stateChanged?(state)
        }
    }

    // Keep an instance for performance and easy access.
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    // Use State to store relevant data.
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

    func day(for date: Date) -> String {
        return dayFormatter.string(from: date)
    }

    func loadWeatherForecast(for location: CLLocationCoordinate2D) {
        state = .loading
        
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

// Make the view model responsible for formatting and updating data in the table view.
extension ForecastViewModel: UITableViewDataSource {
    subscript(_ indexPath: IndexPath) -> DarkSkyDaily? {
        guard let forecast = state.getForecast() else {
            return nil
        }
        return forecast.daily.data[indexPath.row]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.getForecast()?.daily.data.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        guard let dailyForecast = self[indexPath] else {
            return cell
        }
        configureCell(cell, with: dailyForecast)
        return cell
    }

    func configureCell(_ cell: UITableViewCell, with daily: DarkSkyDaily) {
        cell.textLabel?.text = day(for: daily.time)
        cell.detailTextLabel?.text = daily.temperatureSummary
        cell.imageView?.image = daily.iconImage
    }
}

// It's the view model's job to make the data pretty for the view.
extension DarkSkyDaily {
    var iconImage: UIImage? {
        return icon.map { UIImage(imageLiteralResourceName: $0) }
    }

    var highTemperatureString: String {
        guard let temperatureHigh = temperatureHigh else {
            return ""
        }
        return "H:\(Int(temperatureHigh))º"
    }

    var lowTemperatureString: String {
        guard let temperatureLow = temperatureLow else {
            return ""
        }
        return "L:\(Int(temperatureLow))º"
    }

    var temperatureSummary: String {
        return highTemperatureString + " " + lowTemperatureString
    }
}
