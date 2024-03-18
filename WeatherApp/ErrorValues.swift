//
//  ErrorValues.swift
//  WeatherApp
//
//  Created by Shaikh Islam on 3/14/24.
//

import Foundation

enum CityLoadingError: Error {
    case networkError(Error)
    case dataParsingError(String)
}

