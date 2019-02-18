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

/// A UIView subclass that draws a clock in the view's frame.
class UIClockView: UIView {
    
    /// An enum that provides the differnt types clocks available
    enum ClockType {
        /// Not currently available to use.
        case sunrise
        /// A clock type for day mode
        case day
        /// Not currently available to use.
        case sunset
        /// A clock type for night mode
        case night
        
        /// An instance returing the appropraite content color based on the clock type.
        var contentItemsColor: UIColor {
            switch self {
            case .day:
                return .clockinDark
            default:
                return .clockinLight
            }
        }
        
        /// An instance returing the appropraite backgrounf color based on the clock type.
        var clockBGColor: UIColor {
            switch self {
            case .day:
                return .clockinLight
            default:
                return .clockinDark
            }
        }
    }
    
    // A set used to store all layer names. To avoid re-drawing layers
    fileprivate var sublayerNames: Set<String> = ["Clock Base Background", "Rounded Clock Background", "Clock Hour Hand", "Clock Minute Hand", "Clock Second Hand", "Clock Large Ticks", "Clock Small Ticks"]
    
    // The parent layer of the clock ticks
    fileprivate var backgroundLayer: CALayer = {
        let layer = CALayer()
        layer.name = "Clock Base Background"
        return layer
    }()
    
    // The parent layer of the clock hands
    fileprivate var roundedClockLayer: CALayer = {
        let layer = CALayer()
        layer.name = "Rounded Clock Background"
        return layer
    }()
    
    // Hour ticks
    fileprivate var largeTickParentLayer: CAReplicatorLayer = {
        let layer = CAReplicatorLayer()
        layer.name = "Clock Large Ticks"
        layer.instanceCount = 12
        // full circle (in radians) / instance count = angle difference between each tick
        layer.instanceTransform = CATransform3DMakeRotation((2.0 * .pi) / 12, 0, 0, 1)
        return layer
    }()
    
    // Second ticks
    fileprivate var smallTickParentLayer: CAReplicatorLayer = {
        let layer = CAReplicatorLayer()
        layer.name = "Clock Small Ticks"
        layer.instanceCount = 60
        // full circle (in radians) / instance count = angle difference between each tick
        layer.instanceTransform = CATransform3DMakeRotation((2.0 * .pi) / 60, 0, 0, 1)
        return layer
    }()
    
    // Hour hand layer
    fileprivate var clockHourHandLayer: CALayer = {
        let layer = CALayer()
        layer.name = "Clock Hour Hand"
        return layer
    }()
    
    // Minute hand layer
    fileprivate var clockMinuteHandLayer: CALayer = {
        let layer = CALayer()
        layer.name = "Clock Minute Hand"
        return layer
    }()
    
    // Second hand layer
    fileprivate var clockSecondHandLayer: CALayer = {
        let layer = CALayer()
        layer.name = "Clock Second Hand"
        return layer
    }()
    
    /// An instance used to update the view's layers colors based on the time of the day
    public var type: ClockType = .day {
        didSet {
            guard oldValue != type else { return }
            self.updateLayerColors()
        }
    }
    
    override func draw(_ rect: CGRect) {
        // Base case used to avoid re-drawing layers when using `UIClockView` in a reusable cell by removing previously drawn layers.
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
    
    // A method that handles drawing the base layers of the clock view.
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
    
    // A method that handles drawing the clock tips/ticks on the bg layer.
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
    
    // A method that handles drawing the hand layers and setting their anchor point to the center of the clock view
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
    
    // A method that's executed when `self.type` is changed to update the colors of the clock layers based on the time of the day.
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
    
    // A method that calculates the angles of the hand layers @ a specific time. Returns a tuple of (hour's angle, min's angle, sec's angle)
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
        // Removing all animation from the layers before adding the clock ticking animation
        clockSecondHandLayer.removeAllAnimations()
        clockMinuteHandLayer.removeAllAnimations()
        clockHourHandLayer.removeAllAnimations()
        
        // Getting the angles of the hand layers.
        let times = self.set(time: time)
        
        // Creating clockwise rotation animation for the second hand layer. Duration in seconds = 60. And the animation runs infinitely unless this method is called again.
        // Meaning it'd take the second hand 60 seconds to complete a full orientation
        let secondHandLayerAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        secondHandLayerAnimation.fromValue = (times.2 + 180) * (.pi / 180)
        secondHandLayerAnimation.byValue = 2 * CGFloat.pi
        secondHandLayerAnimation.repeatCount = .infinity
        secondHandLayerAnimation.duration = 60
        secondHandLayerAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        secondHandLayerAnimation.isRemovedOnCompletion = false
        clockSecondHandLayer.add(secondHandLayerAnimation, forKey: nil)
        
        // Creating clockwise rotation animation for the second hand layer. Duration in seconds = 3600. And the animation runs infinitely unless this method is called again.
        // Meaning it'd take the minute hand 1 minute to complete a full orientation
        let minuteHandLayerAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        minuteHandLayerAnimation.fromValue = (times.1 + 180) * (.pi / 180)
        minuteHandLayerAnimation.byValue = 2 * CGFloat.pi
        minuteHandLayerAnimation.repeatCount = .infinity
        minuteHandLayerAnimation.duration = 3600
        minuteHandLayerAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        minuteHandLayerAnimation.isRemovedOnCompletion = false
        clockMinuteHandLayer.add(minuteHandLayerAnimation, forKey: nil)
        
        // Creating clockwise rotation animation for the second hand layer. Duration in seconds = 43200. And the animation runs infinitely unless this method is called again.
        // Meaning it'd take the minute hand 1 hour to complete a full orientation
        let hourHandLayerAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        hourHandLayerAnimation.fromValue = (times.0 + 180)  * (.pi / 180)
        hourHandLayerAnimation.byValue = 2 * CGFloat.pi
        hourHandLayerAnimation.repeatCount = .infinity
        hourHandLayerAnimation.duration = 43200
        hourHandLayerAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        hourHandLayerAnimation.isRemovedOnCompletion = false
        clockHourHandLayer.add(hourHandLayerAnimation, forKey: nil)
    }
    
}
