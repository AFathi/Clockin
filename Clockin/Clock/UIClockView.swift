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
                return .clockinDark
            default:
                return .clockinLight
            }
        }
        
        var clockBGColor: UIColor {
            switch self {
            case .day:
                return .clockinLight
            default:
                return .clockinDark
            }
        }
    }
    
    var sublayerNames: Set<String> = ["Clock Base Background", "Rounded Clock Background", "Clock Hour Hand", "Clock Minute Hand", "Clock Second Hand", "Clock Large Ticks", "Clock Small Ticks"]
    
    var backgroundLayer: CALayer = {
        let layer = CALayer()
        layer.name = "Clock Base Background"
        return layer
    }()
    
    var roundedClockLayer: CALayer = {
        let layer = CALayer()
        layer.name = "Rounded Clock Background"
        return layer
    }()
    
    // Hour ticks
    var largeTickParentLayer: CAReplicatorLayer = {
        let layer = CAReplicatorLayer()
        layer.name = "Clock Large Ticks"
        layer.instanceCount = 12
        // full circle (in radians) / instance count = angle difference between each tick
        layer.instanceTransform = CATransform3DMakeRotation((2.0 * .pi) / 12, 0, 0, 1)
        return layer
    }()
    
    // Second ticks
    var smallTickParentLayer: CAReplicatorLayer = {
        let layer = CAReplicatorLayer()
        layer.name = "Clock Small Ticks"
        layer.instanceCount = 60
        // full circle (in radians) / instance count = angle difference between each tick
        layer.instanceTransform = CATransform3DMakeRotation((2.0 * .pi) / 60, 0, 0, 1)
        return layer
    }()
    
    var clockHourHandLayer: CALayer = {
        let layer = CALayer()
        layer.name = "Clock Hour Hand"
        return layer
    }()
    
    var clockMinuteHandLayer: CALayer = {
        let layer = CALayer()
        layer.name = "Clock Minute Hand"
        return layer
    }()
    
    var clockSecondHandLayer: CALayer = {
        let layer = CALayer()
        layer.name = "Clock Second Hand"
        return layer
    }()
    
    // An instance used to update the view's layers colors based on the time of the day
    var type: ClockType = .day {
        didSet {
            guard oldValue != type else { return }
            self.updateLayerColors()
        }
    }
    
    override func draw(_ rect: CGRect) {
        // Base case used to avoid re-drawing layers when using `UIClockView` in a reusable cell.
        if let sublayers = self.layer.sublayers {
            smallTickParentLayer.sublayers?.removeAll()
            largeTickParentLayer.sublayers?.removeAll()
            for layer in sublayers {
                if sublayerNames.contains(layer.name ?? "") {
                    layer.removeFromSuperlayer()
                    layer.removeAllAnimations()
                }
            }
        }
        
        self.drawBaseLayers(in: rect)
        self.drawTickLayers(in: rect)
        self.drawHandLayers(in: roundedClockLayer.frame)
    }
    
    fileprivate func drawBaseLayers(in rect: CGRect) {
        backgroundLayer.frame = rect
        backgroundLayer.backgroundColor = (type == .day) ? UIColor.clockBGLight.withAlphaComponent(0.8).cgColor : UIColor.clockBGDark.withAlphaComponent(0.8).cgColor
        backgroundLayer.cornerRadius = rect.size.width / 2
        layer.addSublayer(backgroundLayer)
        
        roundedClockLayer.frame = CGRect(x: 0, y: 0, width: rect.width*0.85, height: rect.height*0.85)
        roundedClockLayer.position = CGPoint(x: backgroundLayer.bounds.width/2, y: backgroundLayer.bounds.height/2)
        roundedClockLayer.cornerRadius = roundedClockLayer.frame.size.width / 2
        roundedClockLayer.backgroundColor = (type == .day) ? UIColor.clockBGLight.cgColor : UIColor.clockBGDark.cgColor
        
        roundedClockLayer.shadowColor = (type == .night) ? UIColor.clockBGLight.cgColor : UIColor.clockBGDark.cgColor
        roundedClockLayer.shadowRadius = 6
        roundedClockLayer.shadowOpacity = 0.4
        roundedClockLayer.shadowOffset = .zero
        backgroundLayer.addSublayer(roundedClockLayer)
    }
    
    fileprivate func drawTickLayers(in rect: CGRect) {
        smallTickParentLayer.frame = rect
        self.layer.addSublayer(smallTickParentLayer)
        
        largeTickParentLayer.frame = rect
        self.layer.addSublayer(largeTickParentLayer)
        
        let smallTickChildLayer = CALayer()
        let pointX = rect.midX - 1.0 / 2.0
        smallTickChildLayer.frame = CGRect(x: pointX, y: 1.5, width: 1.0, height: 4)
        smallTickChildLayer.backgroundColor = (type == .night) ? UIColor.clockinLight.withAlphaComponent(0.4).cgColor : UIColor.clockinDark.withAlphaComponent(0.4).cgColor
        smallTickParentLayer.addSublayer(smallTickChildLayer)
        
        let largeTickChildLayer = CALayer()
        let largePointX = rect.midX - 2.0 / 2.0
        largeTickChildLayer.frame = CGRect(x: largePointX, y: 1.5, width: 3.0, height: 6)
        largeTickChildLayer.backgroundColor = (type == .night) ? UIColor.clockinLight.cgColor : UIColor.clockinDark.cgColor
        largeTickChildLayer.cornerRadius = 1.8
        largeTickParentLayer.addSublayer(largeTickChildLayer)
    }
    
    fileprivate func drawHandLayers(in rect: CGRect) {
        clockSecondHandLayer.anchorPoint = CGPoint(x: 0.5, y: 0.2)
        clockSecondHandLayer.position = CGPoint(x: rect.size.width/2, y: rect.size.height/2)
        clockSecondHandLayer.bounds = CGRect(x: 0, y: 0, width: 1.5, height: rect.size.width*0.65)
        clockSecondHandLayer.backgroundColor = (type == .day) ? UIColor.clockSecondTickLightMode.cgColor : UIColor.clockSecondTickDarkMode.cgColor
        clockSecondHandLayer.cornerRadius = 0.75

        clockMinuteHandLayer.anchorPoint = CGPoint(x: 0.5, y: 0.2)
        clockMinuteHandLayer.position = CGPoint(x: rect.size.width/2, y: rect.size.height/2)
        clockMinuteHandLayer.bounds = CGRect(x: 0, y: 0, width: 2.5, height: (rect.size.width/2) - (rect.size.width*0.1))
        clockMinuteHandLayer.backgroundColor = (type == .day) ? UIColor.clockMinuteTickLightMode.cgColor : UIColor.clockMinuteTickDarkMode.cgColor
        clockMinuteHandLayer.cornerRadius = 1.25

        clockHourHandLayer.anchorPoint = CGPoint(x: 0.5, y: 0.2)
        clockHourHandLayer.position = CGPoint(x: rect.size.width/2, y: rect.size.height/2)
        clockHourHandLayer.bounds = CGRect(x: 0, y: 0, width: 3.5, height: (rect.size.width/2) - (rect.size.width*0.2))
        clockHourHandLayer.backgroundColor = (type == .day) ? UIColor.clockHourTickLightMode.cgColor : UIColor.clockHourTickDarkMode.cgColor
        clockHourHandLayer.cornerRadius = 1.75
        

        roundedClockLayer.addSublayer(clockSecondHandLayer)
        roundedClockLayer.addSublayer(clockMinuteHandLayer)
        roundedClockLayer.addSublayer(clockHourHandLayer)
    }
    
    fileprivate func updateLayerColors() {
        backgroundLayer.backgroundColor = (type == .day) ? UIColor.clockBGLight.withAlphaComponent(0.8).cgColor : UIColor.clockBGDark.withAlphaComponent(0.8).cgColor
        roundedClockLayer.backgroundColor = (type == .day) ? UIColor.clockBGLight.cgColor : UIColor.clockBGDark.cgColor
        roundedClockLayer.shadowColor = (type == .night) ? UIColor.clockBGLight.cgColor : UIColor.clockBGDark.cgColor

        clockHourHandLayer.backgroundColor = (type == .day) ? UIColor.clockHourTickLightMode.cgColor : UIColor.clockHourTickDarkMode.cgColor
        clockMinuteHandLayer.backgroundColor = (type == .day) ? UIColor.clockMinuteTickLightMode.cgColor : UIColor.clockMinuteTickDarkMode.cgColor
        clockSecondHandLayer.backgroundColor = (type == .day) ? UIColor.clockSecondTickLightMode.cgColor : UIColor.clockSecondTickDarkMode.cgColor

        largeTickParentLayer.sublayers?.forEach { layer in
            layer.backgroundColor = (type == .night) ? UIColor.clockinLight.cgColor : UIColor.clockinDark.cgColor
        }
        
        smallTickParentLayer.sublayers?.forEach { layer in
            layer.backgroundColor = (type == .night) ? UIColor.clockinLight.withAlphaComponent(0.4).cgColor : UIColor.clockinDark.withAlphaComponent(0.4).cgColor
        }
    }
    
    fileprivate func set(time: ClockTime) -> (CGFloat, CGFloat, CGFloat) {
        let hourTime = CGFloat(time.hrs * (360 / 12)) + CGFloat(time.mins) * (1.0 / 60) * (360 / 12)
        let minuteTime = CGFloat(time.mins * (360 / 60))
        let secondTime = CGFloat(time.sec * (360 / 60))
        
        clockHourHandLayer.transform = CATransform3DMakeRotation(hourTime / (180 * .pi), 0, 0, 1)
        clockMinuteHandLayer.transform = CATransform3DMakeRotation(minuteTime / (180 * .pi), 0, 0, 1)
        clockSecondHandLayer.transform = CATransform3DMakeRotation(secondTime / (180 * .pi), 0, 0, 1)
        
        return (hourTime, minuteTime, secondTime)
    }
    
    func startAnimation(from time: ClockTime) {
        clockSecondHandLayer.removeAllAnimations()
        clockMinuteHandLayer.removeAllAnimations()
        clockHourHandLayer.removeAllAnimations()
        
        let times = self.set(time: time)
        
        let secondsHandAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        secondsHandAnimation.repeatCount = .infinity
        secondsHandAnimation.duration = 60
        secondsHandAnimation.isRemovedOnCompletion = false
        secondsHandAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        secondsHandAnimation.fromValue = (times.2 + 180) * CGFloat(Double.pi / 180)
        secondsHandAnimation.byValue = 2 * Double.pi
        clockSecondHandLayer.add(secondsHandAnimation, forKey: "secondsHandAnimation")
        
        let minutesHandAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        minutesHandAnimation.repeatCount = Float.infinity
        minutesHandAnimation.duration = 60 * 60
        minutesHandAnimation.isRemovedOnCompletion = false
        minutesHandAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        minutesHandAnimation.fromValue = (times.1 + 180) * CGFloat(Double.pi / 180)
        minutesHandAnimation.byValue = 2 * Double.pi
        clockMinuteHandLayer.add(minutesHandAnimation, forKey: "minutesHandAnimation")
        
        let hoursHandAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        hoursHandAnimation.repeatCount = Float.infinity
        hoursHandAnimation.duration = CFTimeInterval(60 * 60 * 12);
        hoursHandAnimation.isRemovedOnCompletion = false
        hoursHandAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        hoursHandAnimation.fromValue = (times.0 + 180)  * CGFloat(Double.pi / 180)
        hoursHandAnimation.byValue = 2 * Double.pi
        clockHourHandLayer.add(hoursHandAnimation, forKey: "hoursHandAnimation")
    }
    
}
