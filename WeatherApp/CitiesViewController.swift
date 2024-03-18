//
//  CitiesViewController.swift
//  WeatherApp
//
//  Created by Mohamed Shehab on 3/11/24.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
//import PBKHUD

class CitiesViewController: UIViewController {
    
    var cities = [City]()
    var propagatedCity = City()
    
    @IBOutlet weak var cityTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadCities { [weak self] in
            DispatchQueue.main.async {
                self?.cityTableView.reloadData()
            }
        }
    }

    func loadCities(completion: @escaping () -> Void) {
        AF.request(Constants.cityListUrl)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                switch response.result {
                case .success:
                    if let jsonData = try? JSON(data: response.data!) {
                        let cityList = jsonData["cities"].arrayValue
                        for city in cityList {
                            let name = city["name"].stringValue
                            let state = city["state"].stringValue
                            let lat = city["lat"].doubleValue
                            let lng = city["lng"].doubleValue
                            let currentCity = City(name: name, state: state, lat: lat, lng: lng)
                            self.cities.append(currentCity)
                        }
                        DispatchQueue.main.async {
                            completion()
                        }
                    }
                case let .failure(error):
                    print(error)
                }
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWeatherDetailsSegue" {
            if let indexPath = cityTableView.indexPathForSelectedRow {
                let selectedCity = cities[indexPath.row]
                let destination = segue.destination as! ForecastViewController
                destination.cityDetails = selectedCity
            }
        }
    }

}

extension CitiesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cityTableView.dequeueReusableCell(withIdentifier: "cityListCell", for: indexPath)
        
        let cityName = cities[indexPath.row].name
        let cityState = cities[indexPath.row].state
        let nameLable = cell.viewWithTag(100) as! UILabel

        nameLable.text = "\(cityName), \(cityState)"
        return cell
    }
}

extension CitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCity = cities[indexPath.row]
        propagatedCity = selectedCity
        print(selectedCity)
        performSegue(withIdentifier: "toWeatherDetailsSegue", sender: nil)
    }
}
