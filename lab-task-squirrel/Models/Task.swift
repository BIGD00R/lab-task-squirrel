//
//  Task.swift
//  lab-task-squirrel
//
//  Created by Charlie Hieger on 11/15/22.
//

import UIKit
import CoreLocation

class Task {
    let title: String
    let description: String
    var image: UIImage?
    var imageLocation: CLLocation?
    var isComplete: Bool {
        image != nil
    }

    init(title: String, description: String) {
        self.title = title
        self.description = description
    }

    func set(_ image: UIImage, with location: CLLocation) {
        self.image = image
        self.imageLocation = location
    }
}

extension Task {
    static var mockedTasks: [Task] {
        return [
            Task(title: "Favorite Local Restuaurant 🍽",
                 description: "Better be 5 star material"),
            Task(title: "Favorite place to walk 🥾",
                 description: "as long as there is no gators on the trail 🐊"),
            Task(title: "Favorite Place to Fish ",
                 description: "I need a good spot to go fishing"),
            Task(title: "Favorite place to Hangout ",
                 description: "chilling is the way"),        ]
    }
}
