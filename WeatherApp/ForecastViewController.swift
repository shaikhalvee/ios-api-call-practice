//
//  ForecastViewController.swift
//  WeatherApp
//
//  Created by Mohamed Shehab on 3/11/24.
//

import UIKit
import Alamofire
import SwiftyJSON


class ForecastViewController: UIViewController {
    
    var cityDetails: City?
    var forecastDetails = [Forecast]()
    var forecastDetailsUrl: String = ""

    @IBOutlet weak var forecastTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ForecastTableViewCell", bundle: nil)
        forecastTableView.register(nib, forCellReuseIdentifier: "ForecastTableViewCell")

        getForecastUrl { [weak self] result in
            DispatchQueue.main.async {  [self] in
                switch result {
                case .success(let forecastUrl):
                    self?.forecastDetailsUrl = forecastUrl
                    getForecastDetails { [weak self] in
                        self?.forecastTableView.reloadData()
                    }
                case .failure(let failure):
                    print("Failure occurred: \(failure)")
                }
            }
        }
    }
    
    func getForecastUrl(completion: @escaping (Result<String, CityLoadingError>) -> Void) {
        if cityDetails != nil && cityDetails?.lat != nil && cityDetails?.lng != nil {
            let prepareUrl: String = Constants.forecastBasicUrl + "\(cityDetails!.lat),\(cityDetails!.lng)"
            print("prepared url: \(prepareUrl)")
            AF.request(prepareUrl).validate(statusCode: 200..<300)
                .validate(contentType: ["application/geo+json"])
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let jsonData = try JSON(data: data)
                            if let forecastUrl = jsonData["properties"]["forecast"].string {
                                print("forecast url got: \(forecastUrl)")
                                completion(.success(forecastUrl))
                            }
                        } catch {
                            completion(.failure(.dataParsingError("Invalid data format")))
                        }
                    case .failure(let error):
                        completion(.failure(.networkError(error)))
                        print("error in request: \(error)")
                    }
                }
        }
        
    }
    
    func getForecastDetails(completion: @escaping () -> Void) {
        if self.forecastDetailsUrl != "" {
            AF.request(forecastDetailsUrl)
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/geo+json"])
                .responseData { response in
                    switch response.result {
                    case .success:
                        if let jsonData = try? JSON(data: response.data!) {
                            let forecastList = jsonData["properties"]["periods"].arrayValue
                            for forecast in forecastList {
                                let name = forecast["name"].stringValue
                                let startTime = forecast["forecast"].stringValue
                                let temperature = forecast["temperature"].stringValue
                                let temperatureUnit = forecast["temperatureUnit"].stringValue
                                let relativeHumidity = forecast["relativeHumidity"]["relativeHumidity"].stringValue
                                let windSpeed = forecast["windSpeed"].stringValue
                                let iconUrl = forecast["icon"].stringValue
                                let shortForecast = forecast["shortForecast"].stringValue
                                
                                let currentForecast = Forecast(name: name, startTime: startTime, temperature: temperature, temperatureUnit: temperatureUnit, relativeHumidity: relativeHumidity, windSpeed: windSpeed, iconUrl: iconUrl, shortForecast: shortForecast)
                                self.forecastDetails.append(currentForecast)
                            }
                            DispatchQueue.main.async {
//                                self.forecastTableView.reloadData()
                                completion()
                            }
                        }
                    case let .failure(error):
                        print(error)
                    }
                }
        } else {
            print("forecast url isn't populated: \(forecastDetailsUrl)")
        }
    }

}

extension ForecastViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        forecastDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = forecastTableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell", for: indexPath) as! ForecastTableViewCell
        
         // Populate the forecast
        let forecast = forecastDetails[indexPath.row]
        // Display user data in the cell
        
        let nameLabel = cell.veiwWithTag(100) as ! UILabel
        let startTimeLabel = cell.veiwWithTag() as ! UILabel
        let temperatureLabel = cell.veiwWithTag() as ! UILabel
        let temperatureUnitLabel = cell.veiwWithTag() as ! UILabel
        let relativeHumidityLabel = cell.veiwWithTag() as ! UILabel
        let windSpeedLabel = cell.veiwWithTag() as ! UILabel
        let iconUrlLabel = cell.veiwWithTag() as ! UILabel
        let shortForecastLabel = cell.veiwWithTag() as ! UILabel

        nameLabel.text = forecast.name
        startTimeLabel.text = forecast.startTime
        temperatureLabel.text = forecast.temperature
        temperatureUnitLabel.text = forecast.temperatureUnit
        relativeHumidityLabel.text = forecast.relativeHumidity
        windSpeedLabel.text = forecast.windSpeed
        iconUrlLabel.text = forecast.iconUrl
        shortForecastLabel.text = forecast.shortForecast
        
        return cell
    }
    
    
}

