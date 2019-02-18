//
//  HomeTableCell.swift
//  Clockin
//
//  Created by Ahmed Bekhit on 2/15/19.
//  Copyright © 2019 Ahmed Bekhit. All rights reserved.
//

import UIKit

class HomeTableCell: UITableViewCell {

    var cellMode: UIClockView.ClockType = .day {
        didSet {
            self.updateColors()
        }
    }
    
    var cellContentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 35
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var cityTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Black", size: 25)
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
        label.text = " Now"
        label.textColor = UIColor(red: 104/255, green: 104/255, blue: 104/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var tempratureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Black", size: 22)
        label.text = "18°C"
        label.textColor = .clockinDark
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var currentTime: ClockTime!
    
    var childrenViews = [UIView]()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        self.prepareCellLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(didDeviceRotate), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.2, initialSpringVelocity: 1.75, options: .curveEaseOut, animations: {
                self.transform = self.transform.scaledBy(x: 0.9, y: 0.9)
            })
        }else{
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.65, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
                self.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func didDeviceRotate() {
        self.clockView.setNeedsDisplay()
    }
    
    fileprivate func updateColors() {
        UIView.animate(withDuration: 0.3) {
            self.cellContentView.backgroundColor = self.cellMode.clockBGColor
            self.cityTitleLabel.textColor = self.cellMode.contentItemsColor
            self.locationIndicator.tintColor = self.cellMode.contentItemsColor
            self.clockView.type = self.cellMode
            self.tempratureLabel.textColor = self.cellMode.contentItemsColor
            
        }
    }
    
    fileprivate func prepareCellLayout() {
        childrenViews = [cellContentView, cityTitleLabel, locationIndicator, clockView, timeDifferenceLabel, tempratureLabel]
        childrenViews.forEach { childView in
            if childView == cellContentView {
                addSubview(childView)
            }else{
                cellContentView.addSubview(childView)
            }
        }
        
        NSLayoutConstraint.activate([
            // MARK:- Cell content view constraints
            cellContentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            cellContentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            cellContentView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.85),
            cellContentView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            // MARK:- Location indicator constraints
            locationIndicator.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 16),
            locationIndicator.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -16),
            locationIndicator.widthAnchor.constraint(equalToConstant: 25),
            locationIndicator.heightAnchor.constraint(equalTo: locationIndicator.widthAnchor, multiplier: 1),
            
            // MARK:- City title label constraints
            cityTitleLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 16),
            cityTitleLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 16),
            cityTitleLabel.widthAnchor.constraint(lessThanOrEqualTo: cellContentView.widthAnchor, multiplier: 0.7),
            cityTitleLabel.heightAnchor.constraint(lessThanOrEqualTo: cellContentView.heightAnchor, multiplier: 0.35),
            
            // MARK:- Clock view constraints
            clockView.widthAnchor.constraint(lessThanOrEqualTo: cellContentView.widthAnchor, multiplier: 0.6),
            clockView.heightAnchor.constraint(equalTo: clockView.widthAnchor, multiplier: 1),
            clockView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -16),
            clockView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            
            // MARK:- Time difference label constraints
            timeDifferenceLabel.bottomAnchor.constraint(equalTo: clockView.bottomAnchor),
            timeDifferenceLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 16),
            timeDifferenceLabel.trailingAnchor.constraint(equalTo: clockView.leadingAnchor, constant: -5),
            
            // MARK:- Temprature label constraints
            tempratureLabel.bottomAnchor.constraint(equalTo: timeDifferenceLabel.topAnchor, constant: -5),
            tempratureLabel.leadingAnchor.constraint(equalTo: timeDifferenceLabel.leadingAnchor),
            tempratureLabel.trailingAnchor.constraint(equalTo: clockView.leadingAnchor, constant: -5),
            
        ])
        
    }
    

}
