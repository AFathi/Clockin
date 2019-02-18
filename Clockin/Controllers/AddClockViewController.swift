//
//  AddClockViewController.swift
//  Clockin
//
//  Created by Ahmed Bekhit on 2/15/19.
//  Copyright © 2019 Ahmed Bekhit. All rights reserved.
//

import UIKit

class AddClockViewController: UIViewController {

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
        label.text = "Select Timezone"
        label.font = UIFont(name: "Avenir-Heavy", size: 32)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Declaring & initializing the close button
    var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "closeIcon"), for: .normal)
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Declaring & initializing the table view used to display a list of timezones avaialble to add
    var timezonesTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var childrenViews = [UIView]()

    // Declaring and intializing the array storing the timzones available
    var allTimezones: [ClockTime.ClockTimezone] = {
        var timezones = ClockTime.allTimezones
        // sorting ascendingly based on city
        timezones.sort { timezoneA, timezoneB in
            return timezoneA.city.first ?? Character("") < timezoneB.city.first ?? Character("")
        }
        
        return timezones
    }()
    
    /// An array of the user's default timezones. The array must be passed by the previous controller.
    var userCurrentTimezones: [ClockTime.ClockTimezone] = []
    
    // Overriding statusbar default color and changing it to a light/white color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareUILayout()
    }
    
    func prepareUILayout() {
        closeButton.addTarget(self, action: #selector(closeHandler(sender:)), for: .touchUpInside)
        
        timezonesTableView.delegate = self
        timezonesTableView.dataSource = self
        timezonesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "timezoneCell")
        
        childrenViews = [backgroundImageView, titleLabel, closeButton, timezonesTableView]
        
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
            
            // MARK:- Close button constraints
            closeButton.widthAnchor.constraint(equalToConstant: 50),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            // MARK:- Clock table view constraints
            timezonesTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            timezonesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            timezonesTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            timezonesTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            ])

    }
    
    @objc func closeHandler(sender: UIButton) {
        self.dismiss(animated: true)
    }
}

// MARK: UITableView Delegates & DataSource methods
extension AddClockViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTimezones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "timezoneCell", for: indexPath)
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "timezoneCell")

        let cellTimezone = allTimezones[indexPath.row]
        
        cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 18)
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = "\(cellTimezone.city), \(cellTimezone.continent)"
        
        cell.detailTextLabel?.font = UIFont(name: "Avenir-Medium", size: 12)
        cell.detailTextLabel?.textColor = .lightGray
        cell.detailTextLabel?.text = "Tap to select"
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellTimezone = allTimezones[indexPath.row]
        userCurrentTimezones.append(cellTimezone)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(userCurrentTimezones), forKey: "timezoneClockinDefaults")
        NotificationCenter.default.post(name: Notification.Name("didSelectTimezone"), object: nil)
        self.dismiss(animated: true)
    }
}
