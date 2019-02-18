//
//  UIColor+Clockin.swift
//  Clockin
//
//  Created by Ahmed Bekhit on 2/16/19.
//  Copyright © 2019 Ahmed Bekhit. All rights reserved.
//

import UIKit

extension UIColor {
    // 19, 18, 50
    static var clockBGDark: UIColor {
        return UIColor(red: 19/255, green: 18/255, blue: 50/255, alpha: 1)
    }
    
    static var clockinDark: UIColor {
        return UIColor(red: 8/255, green: 8/255, blue: 30/255, alpha: 1)
    }
    static var clockSecondTickDarkMode: UIColor {
        return UIColor(red: 255/255, green: 56/255, blue: 88/255, alpha: 1)
    }
    
    static var clockMinuteTickDarkMode: UIColor {
        return UIColor(red: 234/255, green: 243/255, blue: 249/255, alpha: 1)
    }
    
    static var clockHourTickDarkMode: UIColor {
        return UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1)
    }
    
    static var clockBGLight: UIColor {
        return UIColor(red: 222/255, green: 231/255, blue: 240/255, alpha: 1)
    }
    static var clockinLight: UIColor {
        return UIColor(red: 234/255, green: 243/255, blue: 249/255, alpha: 1)
    }
    static var clockSecondTickLightMode: UIColor {
        return UIColor(red: 255/255, green: 6/255, blue: 90/255, alpha: 1)
    }
    
    static var clockMinuteTickLightMode: UIColor {
        return UIColor(red: 200/255, green: 210/255, blue: 228/255, alpha: 1)
    }
    
    static var clockHourTickLightMode: UIColor {
        return UIColor(red: 23/255, green: 11/255, blue: 54/255, alpha: 1)
    }
}
