//
//  City.swift
//  WeatherApp
//
//  Created by Shaikh Islam on 3/11/24.
//

import Foundation

class City {
    var name: String
    var state: String
    var lat: Double
    var lng: Double
    
    init(name: String? = nil, state: String? = nil, lat: Double? = nil, lng: Double? = nil) {
        self.name = name ?? ""
        self.state = state ?? ""
        self.lat = lat ?? 0
        self.lng = lng ?? 0
    }
}
