//
//  WeatherCollectionViewCell.swift
//  MyWeather
//
//  Created by huayi geng on 2021-10-04.
//  Copyright © 2021 huayi geng. All rights reserved.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {

    static let identifier = "WeatherCollectionViewCell"
    
    @IBOutlet var icon: UIImageView!
    @IBOutlet var temp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    static func nib() -> UINib{
        return UINib(nibName: "WeatherCollectionViewCell", bundle: nil)
    }
    
    func setup(with model: HourlyEntry){
        self.temp.text = String(format:"%.1f", model.temp - 273.15) + "º"
        self.icon.contentMode = .scaleAspectFit
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

}
