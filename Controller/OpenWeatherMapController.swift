//
//  OpenWeatherMapController.swift
//  WeatherApp2
//
//  Created by Yves Dukuze on 07/08/2023.
//

import Foundation

private enum API {
    static let key = "1ac451410617a35f82839cfe2f0884e5"
}


final class OpenWeatherMapController: WebServiceController {
    
    
    let fallbackService: WebServiceController?

    init(fallbackService: WebServiceController? = nil) {
        self.fallbackService = fallbackService
    }
    
    func fetchWeatherData(for city: String,
                          completionHandler: @escaping (String?, WebServiceControllerError?) -> Void) {
        let endpoint = "https://api.openweathermap.org/data/2.5/find?q=\(city)&units=metric&appid=\(API.key)"
        
        // create a string that can be used in URLs
        guard let safeURLString = endpoint.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
            let endpointURL = URL(string: safeURLString) else {
            completionHandler(nil, WebServiceControllerError.invalidURL(endpoint))
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: endpointURL, completionHandler: { (data, response, error) -> Void in
            guard error == nil else {
                if let fallback = self.fallbackService {
                    fallback.fetchWeatherData(for: city, completionHandler: completionHandler)
                } else {
                    completionHandler(nil, WebServiceControllerError.forwarded(error!))
                }
                return
            }
            guard let responseData = data else {
                if let fallback = self.fallbackService {
                    fallback.fetchWeatherData(for: city, completionHandler: completionHandler)
                } else {
                    completionHandler(nil, WebServiceControllerError.invalidPayload(endpointURL))
                }
                return
            }

            // decode json
            let decoder = JSONDecoder()
            do {
                let weatherList = try decoder.decode(OpenWeatherMapContainer.self, from: responseData)
                guard let weatherInfo = weatherList.list?.first,
                    let weather = weatherInfo.weather.first?.main,
                    let temperature = weatherInfo.main.temp else {
                    completionHandler(nil, WebServiceControllerError.invalidPayload(endpointURL))
                    return
                }

                // compose weather information
                let weatherDescription = "\(weather) \(temperature) °C"
                completionHandler(weatherDescription, nil)
            } catch let error {
                completionHandler(nil, WebServiceControllerError.forwarded(error))
            }
        })
        
        dataTask.resume()
    }
}
