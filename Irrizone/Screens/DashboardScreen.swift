//
//  ViewController.swift
//  Irrizone
//
//  Created by Jerry Turcios on 2/15/20.
//  Copyright © 2020 Jerry Turcios. All rights reserved.
//

import Charts
import UIKit

class DashboardScreen: UIViewController {
    @IBOutlet var chartView: LineChartView!

    var lineChartHumidityEntries = [ChartDataEntry]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDashboardScreen()
        fetchReadingData()
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

    private func fetchReadingData() {
        let endpoint = API.endpoint
        let url = URL(string: endpoint)

        DispatchQueue.global(qos: .userInitiated).async {
            if let url = url {
                let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    guard let data = data else { return }
                    if error != nil { return }

                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data)
                        var dataObject = [Dictionary<String, Any>]()

                        for object in jsonObject as! Dictionary<String, Any> {
                            if object.key == "data" {
                                dataObject = object.value as! [Dictionary<String, Any>]
                            }
                        }

                        for object in dataObject as [Dictionary<String, Any>] {
                            let reading = object["reading"] as! Dictionary<String, Any>
                            let humid = reading["humid"] as! Double
                            let soil = reading["soil"] as! Int
                            let temp = reading["temp"] as! Double
                            let uv = reading["uv"] as! Int

                            print("\(humid) - \(soil) - \(temp) - \(uv)")

                            let value = ChartDataEntry(x: temp, y: humid)
                            self?.lineChartHumidityEntries.append(value)
                        }

                        DispatchQueue.main.async {
                            // Creates the graph once the data is fetched
                            let line1 = LineChartDataSet(entries: self?.lineChartHumidityEntries, label: "Humidity")
                            line1.colors = [NSUIColor.blue]

                            let data = LineChartData()
                            data.addDataSet(line1)

//                            self?.chartView.data = data
//                            self?.chartView.chartDescription?.text = "Humidity based on temperature"
                        }
                    } catch {
                        print("An error occurred: \(error)")
                    }
                }

                task.resume()
            }
        }
    }

    @objc private func openSettings() {
        let ac = UIAlertController(title: "Settings", message: "Please select an option", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Logout", style: .destructive))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}
