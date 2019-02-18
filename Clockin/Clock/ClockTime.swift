//
//  ClockTime.swift
//  Clockin
//
//  Created by Ahmed Bekhit on 2/16/19.
//  Copyright © 2019 Ahmed Bekhit. All rights reserved.
//

import Foundation

/// A class handling the clock's time and timezones.
class ClockTime {
    /// Simple data model used to store timezone id, city, and continent
    struct ClockTimezone: Codable {
        /// Timezone id, example: `America/Los_Angeles`. Get ids from
        var id: String
        /// City name
        var city: String
        /// Continent name
        var continent: String
    }
    
    /// A singleton that can be used to access user's local time
    static var current: ClockTime? {
        let calendar = Calendar.current
        
        guard let timezone = self.getClockTimezone(of: calendar.timeZone.identifier) else { return nil }
        return ClockTime(timezone: timezone)
    }
    
    /// Current hour on the clock
    var hrs: Int = 0
    
    /// Current minute on the clock
    var mins: Int = 0
    
    /// Current second on the clock
    var sec: Int = 0
    
    /// Returns current timezone
    let timezone: ClockTimezone
    
    /// ClockTime initializer
    init(timezone: ClockTimezone) {
        self.timezone = timezone
        
        guard let timeZone = TimeZone(identifier: timezone.id) else { return }
        let date = Date()
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        
        hrs = calendar.component(.hour, from: date)
        mins = calendar.component(.minute, from: date)
        sec = calendar.component(.second, from: date)
    }
    
    // Weather data: https://home.openweathermap.org/
    // Weather api key: 37511eb7ea65300ac5ce410bc40266aa
    // api.openweathermap.org/data/2.5/weather?q=New%20York&APPID=37511eb7ea65300ac5ce410bc40266aa
    static func getWeather(for timezone: ClockTimezone, _ completion: @escaping (_ isSuccess: Bool, _ weather: Double?, _ degreeType: String) -> Void) {
        let query = timezone.city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let apiURL = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(query)&APPID=37511eb7ea65300ac5ce410bc40266aa") {
            callAPI(url: apiURL, headers: [:]) { (success, err, data) in
                if success {
                    if let jsonData = data as? [String: Any],
                    let mainInfo = jsonData["main"] as? [String: Any],
                    let tempInKelvin = mainInfo["temp"] as? Double {
                        let tempInCelsius = tempInKelvin - 273.15
                        completion(true, tempInCelsius, "C")
                    }else{
                        completion(false, nil, "C")
                    }
                }else{
                    completion(false, nil, "C")
                }
            }
        }else{
            completion(false, nil, "C")
        }
    }
    
    // MARK: - HTTP GET Request Method with caching enabled by default
    static func callAPI(url: URL, type: String = "GET", headers: [String: String], enableCache: Bool=true, _ completion: @escaping (Bool, Error?, Any?) -> Void) {
        
        var task: URLSessionDataTask!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = type
        
        let session = URLSession.shared
        
        task = session.dataTask(with: request) { (data, response, error) in
            if let err = error {
                DispatchQueue.main.async(execute: {
                    completion(false, err, nil)
                })
            }else if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    DispatchQueue.main.async(execute: {
                        if enableCache {
                            URLCache.shared.storeCachedResponse(CachedURLResponse(response: response!, data: data), for: task)
                        }
                        completion(true, nil, json)
                    })
                }catch{
                    completion(false, error, nil)
                    return
                }
            }
        }
        
        if enableCache {
            URLCache.shared.getCachedResponse(for: task, completionHandler: { cachedResponse in
                if let data = cachedResponse?.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        DispatchQueue.main.async(execute: {
                            completion(true, nil, json)
                        })
                    }catch{
                        completion(false, error, nil)
                        return
                    }
                }
            })
        }
        
        task.resume()
    }

    
    /// A get-only array that returns a list of timezone available
    static var allTimezones: [ClockTimezone] {
        var timezones = [ClockTimezone]()
        
        for id in TimeZone.knownTimeZoneIdentifiers {
            if let timezone = getClockTimezone(of: id) {
                timezones.append(timezone)
            }
        }
        
        return timezones
    }
    
    /// A get-only array that returns the default list of the user's timezones. Includes added timezones
    /// Access data from `UserDefaults` using key: 'timezoneClockinDefaults'
    static var timezoneClockinDefaults: [ClockTimezone] {
        if let timezoneDefaults = UserDefaults.standard.value(forKey: "timezoneClockinDefaults") as? Data, var allTimes = try? PropertyListDecoder().decode(Array<ClockTime.ClockTimezone>.self, from: timezoneDefaults) {
            // Returns an array with the new local timezone of the user + previously added timezones
            if let current = ClockTime.current, allTimes[0].id != current.timezone.id {
                allTimes[0] = current.timezone
                UserDefaults.standard.set(try? PropertyListEncoder().encode(allTimes), forKey: "timezoneClockinDefaults")
                return allTimes
            }
            
            // Returns an array of the previously added timezones
            return allTimes
        }
        
        if let current = ClockTime.current {
            let timezones = [
                current.timezone,
                ClockTime.ClockTimezone(id: "Europe/Berlin", city: "Berlin", continent: "Europe"),
                ClockTime.ClockTimezone(id: "America/Los_Angeles", city: "Los Angeles", continent: "America"),
                ClockTime.ClockTimezone(id: "Australia/Sydney", city: "Sydney", continent: "Australia")
            ]
            
            UserDefaults.standard.set(try? PropertyListEncoder().encode(timezones), forKey: "timezoneClockinDefaults")
            
            // Returns the local timezone + default timezones, this occurrs if it's the first time the user opens the app
            return timezones
        }
        
        // Returns default timezones if unable to get local timezone
        return [
            ClockTime.ClockTimezone(id: "Europe/Berlin", city: "Berlin", continent: "Europe"),
            ClockTime.ClockTimezone(id: "America/Los_Angeles", city: "Los Angeles", continent: "America"),
            ClockTime.ClockTimezone(id: "Australia/Sydney", city: "Sydney", continent: "Australia")
        ]
    }
    
    /// Generates a ClockTimezone using a given id.
    static func getClockTimezone(of id: String) -> ClockTimezone? {
        let nameComponent = id.components(separatedBy: "/")
        if let continentName = nameComponent.first,
            let cityName = nameComponent.last {
            let city = cityName.replacingOccurrences(of: "_", with: " ")
            let timezone = ClockTimezone(id: id, city: city, continent: continentName)
            return timezone
        }
        
        return nil
    }
    
}
