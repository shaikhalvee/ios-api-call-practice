//
//  ForecastViewController.swift
//  WeatherApp
//
//  Created by Mohamed Shehab on 3/11/24.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import PKHUD

class ForecastViewController: UIViewController {
    
    var cityDetails: City?
    var forecastDetails = [Forecast]()
    var forecastDetailsUrl: String = ""

    @IBOutlet weak var forecastTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ForecastTableViewCell", bundle: nil)
        forecastTableView.register(nib, forCellReuseIdentifier: "ForecastTableViewCell")
        
        // Ensure that a city is selected
        guard let city = cityDetails else {
            print("No city selected")
            return
        }

        let prepareUrl: String = Constants.forecastBasicUrl + "\(cityDetails!.lat),\(cityDetails!.lng)"
        print("prepared url: \(prepareUrl)")
        
        fetchWeatherForecastUrl(url: prepareUrl)
        
    }

    // Fetch the URL for the weather forecast
    func fetchWeatherForecastUrl(url: String) {
        HUD.show(.progress) // Show loading indicator
        
        AF.request(url).responseData { [weak self] response in
            guard let self = self else { return }
            
            HUD.hide() // Hide loading indicator
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if let forecastUrl = json["properties"]["forecast"].string {
                    self.fetchWeatherForecast(forecastUrl: forecastUrl)
                } else {
                    print("Forecast URL not found in JSON response")
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    // Fetch the weather forecast data
    func fetchWeatherForecast(forecastUrl: String) {
        HUD.show(.progress) // Show loading indicator
        
        AF.request(forecastUrl).responseData { [weak self] response in
            guard let self = self else { return }
            HUD.hide() // Hide loading indicator
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self.parseForecastJSON(json)
                self.forecastTableView.reloadData()
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    // Parse the JSON response containing the weather forecast
    func parseForecastJSON(_ json: JSON) {
        if let forecastArray = json["properties"]["periods"].array {
            for forecastJson in forecastArray {
                let name = forecastJson["name"].stringValue
                let date = forecastJson["startTime"].stringValue
                let icon = forecastJson["icon"].stringValue
                let temperature = forecastJson["temperature"].stringValue
                let humidity = forecastJson["relativeHumidity"]["value"].stringValue
                let forecast = forecastJson["shortForecast"].stringValue
                let windSpeed = forecastJson["windSpeed"].stringValue
                let forecastItem = Forecast(name: name, startTime: date, temperature: temperature, relativeHumidity: humidity, windSpeed: windSpeed, iconUrl: icon, shortForecast: forecast)
                self.forecastDetails.append(forecastItem)
                
                // Print the forecast data
                print("Date: \(date), Temperature: \(temperature), Humidity: \(humidity), Forecast: \(forecast), Wind Speed: \(windSpeed)")
            }
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
        
//        let nameLabel = cell.veiwWithTag(100) as ! UILabel
//        let startTimeLabel = cell.veiwWithTag() as ! UILabel
//        let temperatureLabel = cell.veiwWithTag() as ! UILabel
//        let temperatureUnitLabel = cell.veiwWithTag() as ! UILabel
//        let relativeHumidityLabel = cell.veiwWithTag() as ! UILabel
//        let windSpeedLabel = cell.veiwWithTag() as ! UILabel
//        let iconUrlLabel = cell.veiwWithTag() as ! UILabel
//        let shortForecastLabel = cell.veiwWithTag() as ! UILabel
        
        cell.dateLabel.text = forecast.startTime
        cell.temperatureLabel.text = forecast.temperature
        cell.humidityLabel.text = "Humidity: \(forecast.relativeHumidity ?? "N/A")%"
        cell.forecastLabel.text = forecast.shortForecast
        cell.windSpeedLabel.text = "Wind Speed: \(forecast.windSpeed ?? "N/A")"

        if let url = URL(string: forecast.iconUrl!) {
            cell.forecastImageView.kf.setImage(with: url)
        }
        
        return cell
    }
    
    
}

/*
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
 */
