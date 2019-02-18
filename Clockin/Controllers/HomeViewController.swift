//
//  HomeViewController.swift
//  Clockin
//
//  Created by Ahmed Bekhit on 2/15/19.
//  Copyright © 2019 Ahmed Bekhit. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    // Weather data: https://home.openweathermap.org/
    
    // Declaring & initializing the image view used for the home screen's background.
    var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "homeBG"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Declaring & initializing the view's title label
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Clockin"
        label.font = UIFont(name: "Avenir-Heavy", size: 38)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Declaring & initializing the add button that will be used to add new clocks with different timezones
    var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "addIcon"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    // Declaring & initializing the table view used to display a list analog clocks worldwide
    var clocksTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var childrenViews = [UIView]()
    
    let userCurrentTimezone = ClockTime.current?.timezone
    
    var userTimes: [ClockTime.ClockTimezone] = {
        if let current = ClockTime.current {
            let timezone = current.timezone
            return [timezone] + ClockTime.allTimezones
        }
        return ClockTime.allTimezones
    }()
    // Handling when userTimes array is modified
    {
        didSet {
            clocksTableView.reloadData()
        }
    }
    
    // Overriding statusbar default color and changing it to a light/white color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareUILayout()
    }
    
    // A method that handles activating the view's constraints
    func prepareUILayout() {
        
        addButton.addTarget(self, action: #selector(addTimezoneHandler(sender:)), for: .touchUpInside)
        
        clocksTableView.delegate = self
        clocksTableView.dataSource = self
        clocksTableView.register(HomeTableCell.self, forCellReuseIdentifier: "ClockCell")
        
        childrenViews = [backgroundImageView, titleLabel, addButton, clocksTableView]
        
        childrenViews.forEach { childView in
            view.addSubview(childView)
        }
        
        NSLayoutConstraint.activate([
            // MARK:- Background image view constraints
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // MARK:- Title label constraints
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            // MARK:- Add button constraints
            addButton.widthAnchor.constraint(equalToConstant: 50),
            addButton.heightAnchor.constraint(equalTo: addButton.widthAnchor),
            addButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            // MARK:- Clock table view constraints
            clocksTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            clocksTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            clocksTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            clocksTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

        ])
    }
    
    
    @objc func addTimezoneHandler(sender: UIButton) {
    }
}


// MARK: UITableView Delegates & DataSource methods
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userTimes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ClockCell") as? HomeTableCell {
            let cellTime = userTimes[indexPath.row]
            let clockTime = ClockTime(timezone: cellTime)
            let timeZone = TimeZone.init(identifier: cellTime.id)
            let timeDifference = (timeZone?.secondsFromGMT(for: Date()) ?? 0) / 3600
            
            cell.locationIndicator.isHidden = userCurrentTimezone?.id ?? "" != cellTime.id
            cell.cellMode = (clockTime.hrs >= 18 || clockTime.hrs < 5) ? .night : .day
            cell.clockView.startAnimation(from: clockTime)
            cell.cityTitleLabel.text = "\(cellTime.city)\n\(cellTime.continent)"
            cell.tempratureLabel.text = "🙈°C"
            cell.timeDifferenceLabel.text = "GMT \(timeDifference >= 0 ? "+" : "")\(timeDifference)"
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //if let cell = tableView.cellForRow(at: indexPath) as? HomeTableCell {
            //cell.cellMode = (cell.cellMode == .day) ? .night : .day
        //}
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 300
        }else{
            if self.view.bounds.width > self.view.bounds.height {
                return self.view.bounds.height*0.95
            }else{
                return self.view.bounds.height*0.55
            }
        }
    }
}
