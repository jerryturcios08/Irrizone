//
//  ViewController.swift
//  Irrizone
//
//  Created by Jerry Turcios on 2/15/20.
//  Copyright © 2020 Jerry Turcios. All rights reserved.
//

import UIKit

class DashboardScreen: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDashboardScreen()
    }

    private func setupDashboardScreen() {
        title = "Dashboard"

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Cog Icon"),
            style: .plain,
            target: self,
            action: #selector(openSettings)
        )

        navigationItem.rightBarButtonItem?.tintColor = .black

        tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.tintColor = UIColor(named: "Green")
        tabBarController?.tabBar.shadowImage = UIImage()
    }

    @objc private func openSettings() {
        let ac = UIAlertController(title: "Settings", message: "Please select an option YOU FOOL!!!!", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Logout", style: .destructive))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}
