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
    @IBOutlet var graphTypeView: UISegmentedControl!
    @IBOutlet var currentDateLabel: UILabel!
    @IBOutlet var currentTimeLabel: UILabel!

    var lineChartHumidityEntries = [ChartDataEntry]()

    // Determines the type of data to show
    enum GraphType: String {
        case humidity = "Humidity"
        case soil = "Soil"
        case uv = "UV"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDashboardScreen()
        fetchReadingData(for: .humidity)
    }

    @IBAction func graphTypeChanged(_ sender: UISegmentedControl) {
        switch graphTypeView.selectedSegmentIndex {
        case 0:
            fetchReadingData(for: .humidity)
        case 1:
            fetchReadingData(for: .soil)
        case 2:
            fetchReadingData(for: .uv)
        default:
            break
        }
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

        tabBarController?.tabBar.backgroundColor = .white
        tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.tintColor = UIColor(named: "Green")
        tabBarController?.tabBar.shadowImage = UIImage()

        let calendar = Calendar.current
        let date = Date(timeIntervalSinceNow: 0)

        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let year = calendar.component(.year, from: date)
        currentDateLabel.text = "\(month)/\(day)/\(year)"
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        currentTimeLabel.text = "\(hour):\(minute)"
    }

    private func fetchReadingData(for type: GraphType) {
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
                            let temp = reading["temp"] as! Double
                            let value: ChartDataEntry

                            switch type {
                            case .humidity:
                                let humid = reading["humid"] as! Double
                                value = ChartDataEntry(x: temp, y: humid)
                            case .soil:
                                let soil = reading["soil"] as! Int
                                value = ChartDataEntry(x: temp, y: Double(soil))
                            case .uv:
                                let uv = reading["uv"] as! Int
                                value = ChartDataEntry(x: temp, y: Double(uv))
                            }

                            self?.lineChartHumidityEntries.append(value)
                            self?.lineChartHumidityEntries.sort(by: { $0.x < $1.x })
                        }

                        DispatchQueue.main.async {
                            UIView.transition(with: self!.chartView, duration: 0.4, options: .transitionFlipFromBottom, animations: {
                                // Creates the graph once the data is fetched
                                let line1 = LineChartDataSet(entries: self?.lineChartHumidityEntries, label: "\(type.rawValue)")
                                line1.colors = [NSUIColor.systemGreen]
                                line1.circleColors = [NSUIColor.systemYellow]

                                let data = LineChartData()
                                data.addDataSet(line1)

                                self?.chartView.data = data
                                self?.chartView.chartDescription?.text = "\(type.rawValue) based on temperature"
                            })
                        }
                    } catch {
                        DispatchQueue.main.async {
                            let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "Okay", style: .default))
                            self?.present(ac, animated: true)
                        }
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
