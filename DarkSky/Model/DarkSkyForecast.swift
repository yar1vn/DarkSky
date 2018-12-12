//
//  DarkSkyForecast.swift
//  DarkSky
//
//  Created by Yariv Nissim on 12/10/18.
//  Copyright © 2018 Yariv. All rights reserved.
//

import Foundation

// Used quicktype app to generate this JSON with some modifications (mostly manually set Date types).
// https://itunes.apple.com/us/app/paste-json-as-code-quicktype/id1330801220?mt=12

protocol DarkSkyDailyContainer {
    var daily: DarkSkyDaily! { get set }
}

struct DarkSkyForecast: Codable, Hashable {
    let latitude, longitude: Double
    let timezone: String
    let daily: DarkSkyDailySummary
}

struct DarkSkyDailySummary: Codable, Hashable {
    let summary: String
    let icon: String
    let data: [DarkSkyDaily]
}

struct DarkSkyDaily: Codable, Hashable {
    let time: Date
    let apparentTemperatureHigh: Double
    let apparentTemperatureHighTime: Date
    let apparentTemperatureLow: Double
    let apparentTemperatureLowTime: Date
    let summary: String?
    let icon: String?
    let sunriseTime: Date?
    let sunsetTime: Date?
    let moonPhase: Double?
    let precipIntensity: Double?
    let precipIntensityMax: Double?
    let precipIntensityMaxTime: Date?
    let precipProbability: Double?
    let precipType: String?
    let temperatureHigh: Double?
    let temperatureHighTime: Date?
    let temperatureLow: Double?
    let temperatureLowTime: Date?
    let dewPoint: Double?
    let humidity: Double?
    let pressure: Double?
    let windSpeed: Double?
    let windGust: Double?
    let windGustTime: Date?
    let windBearing: Int?
    let cloudCover: Double?
    let uvIndex: Int?
    let uvIndexTime: Date?
    let visibility: Double?
    let ozone: Double?
}
