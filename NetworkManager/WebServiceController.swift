//
//  WebServiceController.swift
//  WeatherApp2
//
//  Created by Yves Dukuze on 07/08/2023.
//

import Foundation

// NOTE  This is the equivalent to Networkable/
public protocol WebServiceController {
    init(fallbackService: WebServiceController?)
    
    var fallbackService: WebServiceController? { get }
    
    func fetchWeatherData(for city: String,
                          completionHandler: @escaping(String?, WebServiceControllerError?) -> Void)
}

// MARK: - WebServiceControllerError
public enum WebServiceControllerError: Error {
    case invalidURL(String)
    case invalidPayload(URL)
    case forwarded(Error)
}
