//
//  SensorCell.swift
//  Irrizone
//
//  Created by Jerry Turcios on 2/15/20.
//  Copyright © 2020 Jerry Turcios. All rights reserved.
//

import UIKit

class SensorCell: UITableViewCell {
    @IBOutlet var sensorName: UILabel!
    @IBOutlet var setManualButton: UIButton!
    @IBOutlet var setAutoButton: UIButton!
    @IBOutlet var setOffButton: UIButton!

    func setupCell(for sensor: Sensor) {
//        sensorName.text = sensor.nodeId
    }
}
