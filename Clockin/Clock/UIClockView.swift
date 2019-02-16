//
//  UIClockView.swift
//  Clockin
//
//  Created by Ahmed Bekhit on 2/15/19.
//  Copyright © 2019 Ahmed Bekhit. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

class UIClockView: UIView {
    enum ClockType {
        case sunrise
        case day
        case sunset
        case night
        
        var contentItemsColor: UIColor {
            switch self {
            case .day:
                return .black
            default:
                return .white
            }
        }
        
        var clockBGColor: UIColor {
            switch self {
            case .day:
                return .white
            default:
                return .black
            }
        }
    }
    
}
