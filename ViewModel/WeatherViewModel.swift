//
//  WeatherStackData.swift
//  WeatherApp2
//
//  Created by Yves Dukuze on 07/08/2023.
//

import Foundation

class WeatherViewModel: ObservableObject {
    @Published var weatherInfo = ""
    
    private let weatherService = OpenWeatherMapController(fallbackService: WeatherStackController())
        
    func fetch(city: String) {
        weatherService.fetchWeatherData(for: city, completionHandler: { (info, error) in
            guard error == nil,
                let weatherInfo = info else {
                    DispatchQueue.main.async {
                        self.weatherInfo = "Could not retrieve weather information for \(city)"
                    }
                return
            }
            DispatchQueue.main.async {
                self.weatherInfo = weatherInfo
            }
        })
    }
}

