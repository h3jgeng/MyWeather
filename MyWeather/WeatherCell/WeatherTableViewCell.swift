//
//  WeatherTableViewCell.swift
//  MyWeather
//
//  Created by huayi geng on 2021-10-03.
//  Copyright © 2021 huayi geng. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
    
    static let identifier = "WeatherTableViewCell"
    
    @IBOutlet var dayLabel : UILabel!
    @IBOutlet var maxTempLabel : UILabel!
    @IBOutlet var minTempLabel : UILabel!
    @IBOutlet var icon : UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
    static func nib() -> UINib{
        return UINib(nibName: "WeatherTableViewCell", bundle: nil)
    }
    
    func setUp(with model: DailyEntry) {
        self.minTempLabel.text = String(format:"%.1f", model.temp.min - 273.15) + "º"
        self.maxTempLabel.text = String(format:"%.1f", model.temp.max - 273.15) + "º"
        self.dayLabel.text = getDay(Date(timeIntervalSince1970: Double(model.dt)))
                
        if model.weather[0].main == "Clear"{
            self.icon.image = UIImage(named: "clear")
        }else if model.weather[0].main == "Clouds"{
            self.icon.image = UIImage(named: "cloud")
        }else if model.weather[0].main == "Rain" {
            self.icon.image = UIImage(named: "rain")
        }else{
            self.icon.image = UIImage(named: "snow")
        }
    }
    
    func getDay(_ date: Date?) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date!)
    }
    
}
