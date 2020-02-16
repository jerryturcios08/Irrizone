//
//  ControlScreen.swift
//  Irrizone
//
//  Created by Jerry Turcios on 2/15/20.
//  Copyright © 2020 Jerry Turcios. All rights reserved.
//

import UIKit

class ControlScreen: UIViewController {
    @IBOutlet var tableView: UITableView!

    var sensors = [Sensor]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupControlScreen()
    }

    private func setupControlScreen() {
        title = "Sensors"
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.tintColor = UIColor(named: "Green")
        tabBarController?.tabBar.shadowImage = UIImage()

        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor(named: "Background")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none

        #if DEBUG
//        sensors.append(Sensor(nodeId: "abc", areaId: "123", humidity: 45, temperature: 60, uv: 2, timestamp: "Yesterday..."))
//        sensors.append(Sensor(nodeId: "akd", areaId: "392", humidity: 30, temperature: 30, uv: 1, timestamp: "Today..."))
//        sensors.append(Sensor(nodeId: "fmx", areaId: "205", humidity: 60, temperature: 50, uv: 6, timestamp: "A few minutes ago..."))
//        sensors.append(Sensor(nodeId: "akv", areaId: "392", humidity: 49, temperature: 70, uv: 8, timestamp: "A millenia ago..."))
//
//        tableView.reloadData()
        #endif

        fetchAllReadings()
    }

    private func fetchAllReadings() {
        let endpoint = "https://d4ae4f0d.ngrok.io/getAllReadings"
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
                            let areaId = object["AreaID"] as! String
                            let deviceType = object["devicetype"] as! String

                            let idObject = object["_id"] as! Dictionary<String, Any>
                            let oid = idObject["$oid"] as! String

                            let reading = object["reading"] as! Dictionary<String, Any>
                            let deviceId = reading["deviceID"] as! String
                            let humid = reading["humid"] as! Double
                            let lat = reading["lat"] as! Double
                            let lon = reading["lon"] as! Double
                            let soil = reading["soil"] as! Int
                            let temp = reading["temp"] as! Double
                            let time = reading["time"] as! Int
                            let uv = reading["uv"] as! Int

                            let sensor = Sensor(
                                oid: oid,
                                areaId: areaId,
                                deviceType: deviceType,
                                deviceId: deviceId,
                                humidity: humid,
                                latitude: lat,
                                longitude: lon,
                                soil: soil,
                                temperature: temp,
                                timestamp: time,
                                uv: uv
                            )

                            self?.sensors.append(sensor)
                        }

                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    } catch {
                        print("An error occurred: \(error)")
                    }
                }

                task.resume()
            }
        }
    }
}

extension ControlScreen: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensors.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Sensor", for: indexPath) as? SensorCell else {
            fatalError("Error: Unable to dequeue reusable cell for the sensor table view")
        }

        let sensor = sensors[indexPath.row]
        cell.setupCell(for: sensor)
        cell.sensorName.text = "\(indexPath.row + 1). \(sensor.deviceId)"
        cell.backgroundColor = UIColor(named: "Background")

        return cell
    }
}
