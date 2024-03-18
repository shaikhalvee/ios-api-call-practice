//
//  Forecast.swift
//  WeatherApp
//
//  Created by Shaikh Islam on 3/14/24.
//

import Foundation

class Forecast {
    var name: String?
    var startTime: String?
    var temperature: String?
    var temperatureUnit: String?
    var relativeHumidity: String?
    var windSpeed: String?
    var iconUrl: String?
    var shortForecast: String?
    
    init(name: String? = nil, startTime: String? = nil, temperature: String? = nil, temperatureUnit: String? = nil, relativeHumidity: String? = nil, windSpeed: String? = nil, iconUrl: String? = nil, shortForecast: String? = nil) {
        self.name = name ?? ""
        self.startTime = startTime ?? "startTime"
        self.temperature = temperature ?? "temperature"
        self.temperatureUnit = temperatureUnit ?? "F"
        self.relativeHumidity = relativeHumidity ?? "relativeHumidity"
        self.windSpeed = windSpeed ?? "windSpeed mph"
        self.iconUrl = iconUrl ?? ""
        self.shortForecast = shortForecast ?? "shortForecast"
    }
}
