//
//  ClockViewController.swift
//  Clockin
//
//  Created by Ahmed Bekhit on 2/15/19.
//  Copyright © 2019 Ahmed Bekhit. All rights reserved.
//

import UIKit

class ClockViewController: UIViewController {
    
    var currentTimezone: ClockTime.ClockTimezone!
    var clockMode: UIClockView.ClockType = .day {
        didSet {
            self.updateColors()
        }
    }
    
    
    var cityTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Black", size: 40)
        label.numberOfLines = 3
        label.text = "Berlin\nGermany"
        label.textColor = .clockinDark
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var locationIndicator: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "locationArrow"))
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .clockinDark
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var clockView: UIClockView = {
        let clock = UIClockView()
        clock.translatesAutoresizingMaskIntoConstraints = false
        return clock
    }()
    
    var timeDifferenceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Medium", size: 14)
        label.text = "Now"
        label.textColor = UIColor(red: 104/255, green: 104/255, blue: 104/255, alpha: 1)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var tempratureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Black", size: 22)
        label.text = "18°C"
        label.textColor = .clockinDark
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "back"), for: .normal)
        button.tintColor = .clockinDark
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var childrenViews = [UIView]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareUILayout()
        
        // Ping weather API to get city's weather
        ClockTime.getWeather(for: currentTimezone) { (success, temp, tempType) in
            if let temprature = temp, success {
                self.tempratureLabel.text = "\(Int(temprature))°\(tempType)"
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didDeviceRotate), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Enables gesture when navigation bar is hidden
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    // Overriding statusbar default color and changing it to a light/white color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return (clockMode == .night) ? .lightContent : UIStatusBarStyle.default
    }

    fileprivate func prepareUILayout() {
        backButton.addTarget(self, action: #selector(goBackHandler(sender:)), for: .touchUpInside)
        
        childrenViews = [cityTitleLabel, locationIndicator, clockView, timeDifferenceLabel, tempratureLabel, backButton]
        childrenViews.forEach { childView in
            view.addSubview(childView)
        }
        
        let clockViewWidthAnchor: NSLayoutConstraint
        if self.view.bounds.width > self.view.bounds.height {
            clockViewWidthAnchor = clockView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.85)
        }else{
            clockViewWidthAnchor = clockView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.85)
        }
        
        NSLayoutConstraint.activate([
            // MARK:- Location indicator constraints
            locationIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            locationIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            locationIndicator.widthAnchor.constraint(equalToConstant: 25),
            locationIndicator.heightAnchor.constraint(equalTo: locationIndicator.widthAnchor, multiplier: 1),
            
            // MARK:- City title label constraints
            cityTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cityTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            cityTitleLabel.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.7),
            cityTitleLabel.heightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.35),
            
            // MARK:- Clock view constraints
            clockViewWidthAnchor,
            clockView.heightAnchor.constraint(equalTo: clockView.widthAnchor, multiplier: 1),
            clockView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            clockView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 15),
            
            // MARK:- Time difference label constraints
            timeDifferenceLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            timeDifferenceLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            timeDifferenceLabel.widthAnchor.constraint(equalToConstant: 65),
            
            // MARK:- Temprature label constraints
            tempratureLabel.bottomAnchor.constraint(equalTo: timeDifferenceLabel.topAnchor, constant: -5),
            tempratureLabel.trailingAnchor.constraint(equalTo: timeDifferenceLabel.trailingAnchor, constant: -12),
            timeDifferenceLabel.widthAnchor.constraint(equalToConstant: 65),

            // MARK:- Back button constraints
            backButton.widthAnchor.constraint(equalToConstant: 50),
            backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor),
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6)
            
            ])
        
    }

    fileprivate func updateColors() {
        self.view.backgroundColor = self.clockMode.clockBGColor
        self.cityTitleLabel.textColor = self.clockMode.contentItemsColor
        self.locationIndicator.tintColor = self.clockMode.contentItemsColor
        self.clockView.type = self.clockMode
        self.tempratureLabel.textColor = self.clockMode.contentItemsColor
        self.backButton.tintColor = self.clockMode.contentItemsColor
    }
    
    @objc func didDeviceRotate() {
        self.clockView.setNeedsDisplay()
    }
    
    @objc func goBackHandler(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
