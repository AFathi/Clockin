//
//  HomeViewController.swift
//  Clockin
//
//  Created by Ahmed Bekhit on 2/15/19.
//  Copyright © 2019 Ahmed Bekhit. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var childrenViews = [UIView]()
    
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
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
