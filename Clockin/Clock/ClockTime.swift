//
//  ClockTime.swift
//  Clockin
//
//  Created by Ahmed Bekhit on 2/16/19.
//  Copyright © 2019 Ahmed Bekhit. All rights reserved.
//

import Foundation

class ClockTime {
    // Simple data model used to store timezone id, city, and continent
    struct ClockTimezone: Codable {
        var id: String
        var city: String
        var continent: String
    }
    
    // A get-only array that returns a list of timezone available
    static var allTimezones: [ClockTimezone] = {
        var timezones = [ClockTimezone]()
        
        for id in TimeZone.knownTimeZoneIdentifiers {
            if let timezone = getClockTimezone(of: id) {
                timezones.append(timezone)
            }
        }
        
        return timezones
    }()
    
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
    
    static var current: ClockTime? {
        let calendar = Calendar.current

        guard let timezone = self.getClockTimezone(of: calendar.timeZone.identifier) else { return nil }
        return ClockTime(timezone: timezone)
    }
    
    var hrs: Int = 0
    var mins: Int = 0
    var sec: Int = 0
    
    var timezone: ClockTimezone
    
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
}
