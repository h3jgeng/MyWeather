//
//  ViewController.swift
//  MyWeather
//
//  Created by huayi geng on 2021-10-03.
//  Copyright © 2021 huayi geng. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet var table: UITableView!
    var models = [DailyEntry]()
    
    let locationManager = CLLocationManager()
    var coordinates: CLLocation?
    var current: currentWeather?
    var hourlyModels = [HourlyEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // register cells
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        
        view.backgroundColor = UIColor(red: 52 / 255.0, green: 109 / 255.0, blue: 179/255.0, alpha: 1.0)
        table.backgroundColor = UIColor(red: 52 / 255.0, green: 109 / 255.0, blue: 179/255.0, alpha: 1.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpLocation()
        
    }
    
    func setUpLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, coordinates == nil {
            coordinates = locations.first
            // save battery
            locationManager.stopUpdatingLocation()
            requestWeather()
            
        }
    }
    
    func requestWeather() {
        guard let coordinates = coordinates else{
            return
        }
        let long = coordinates.coordinate.longitude
        let lat = coordinates.coordinate.latitude
        
        let url = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(long)&exclude=minutely,alerts&appid=6be12762134063e7fe177222b2f1bb08"
        
        URLSession.shared.dataTask(with: URL(string: url)!){
            (data, response, error) in
            
            // Validation
            guard let data = data, error == nil else{
                print("error")
                return
            }
            
            var result: WeatherResponse?
            do {
                result = try JSONDecoder().decode(WeatherResponse.self, from: data)
            }
            catch {
                print("error: \(error)")
            }
            
            for i in 1..<6 {
                self.models.append((result?.daily[i])!)
            }
            
            // convert data
            
            // update
            self.current = result?.current
            self.hourlyModels = result!.hourly
            
            DispatchQueue.main.async {
                self.table.reloadData()
                self.table.tableHeaderView = self.createTableHeader()
            }
            
        }.resume()
        
        print("long \(long), lat \(lat)")
    }
    
    func createTableHeader() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height / 2 - 45))
        headerView.backgroundColor = UIColor(red: 52 / 255.0, green: 109 / 255.0, blue: 179/255.0, alpha: 1.0)
        let locationLabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width - 20, height:headerView.frame.size.height / 4.5))
        
        let imageView = UIImageView(frame: CGRect(x: view.frame.size.width / 2 - headerView.frame.size.height / 6, y: locationLabel.frame.size.height, width: headerView.frame.size.height / 3, height:headerView.frame.size.height / 3))
        let summaryLabel = UILabel(frame: CGRect(x: 10, y: imageView.frame.size.height + 30, width: view.frame.size.width - 20, height:headerView.frame.size.height / 3))
        let tempLabel = UILabel(frame: CGRect(x: 10, y: 30 + locationLabel.frame.size.height + summaryLabel.frame.size.height, width: view.frame.size.width - 20, height:headerView.frame.size.height / 3))
        
        headerView.addSubview(locationLabel)
        headerView.addSubview(summaryLabel)
        headerView.addSubview(tempLabel)
        headerView.addSubview(imageView)
        
        locationLabel.textAlignment = .center
        summaryLabel.textAlignment = .center
        tempLabel.textAlignment = .center
        
        
        
        summaryLabel.text = self.current?.weather[0].description
        locationLabel.text = "Current Location"
        tempLabel.text = String(format:"%.1f", self.current!.temp - 273.15) + "º"
        tempLabel.font = UIFont(name: "Helvetica-Bold", size: 43)
        
        if self.current?.weather[0].main == "Clear"{
            imageView.image = UIImage(named: "clear")
        }else if self.current?.weather[0].main == "Clouds" || self.current?.weather[0].main == "Smoke" {
            imageView.image = UIImage(named: "cloud")
        }else if self.current?.weather[0].main == "Rain" {
            imageView.image = UIImage(named: "rain")
        }else{
            imageView.image = UIImage(named: "snow")
        }
        
        return headerView
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return models.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        if section == 0 {
            title = "Houlry"
        }else{
            title = "Next 5 days"
        }
        
        return title
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor(red: 52 / 255.0, green: 109 / 255.0, blue: 179/255.0, alpha: 1.0)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.black
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier, for: indexPath) as! HourlyTableViewCell
            cell.setup(with: self.hourlyModels)
            cell.backgroundColor = UIColor(red: 52 / 255.0, green: 109 / 255.0, blue: 179/255.0, alpha: 1.0)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        if indexPath.row <= 5 {
            cell.setUp(with: models[indexPath.row])
        }
        
        cell.backgroundColor = UIColor(red: 52 / 255.0, green: 109 / 255.0, blue: 179/255.0, alpha: 1.0)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 150.0
        }else{
            return 90.0
        }
    }


}

struct WeatherResponse: Codable {
    let current: currentWeather
    let hourly: [HourlyEntry]
    let daily: [DailyEntry]
    
}

struct currentWeather: Codable{
    let temp: Double
    let weather: [Weather]
}

struct DailyEntry: Codable{
    let dt: Int
    let temp: Temperature
    let weather: [Weather]
}

struct Weather: Codable{
    let main: String
    let description: String
}

struct HourlyEntry: Codable{
    let temp: Double
    let weather: [Weather]
}

struct Temperature: Codable {
    let min: Double
    let max: Double
}




