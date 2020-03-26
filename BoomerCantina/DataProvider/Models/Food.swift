//
//  Food.swift
//  BoomerCantina
//
//  Created by Nicolas Bellon on 19/03/2020.
//  Copyright © 2020 Nicolas Bellon. All rights reserved.
//

import Foundation
import Firebase

struct Food {
    let id: String
    let name: String
    let price: String
    let pictureURL: URL
    let date: Date

    init?(name: String, pictureURL: String, price: String) {
        
        guard let percent = pictureURL.removingPercentEncoding else { return nil }
        
        guard let url = URL(string: percent) else { return nil }
        
        self.name = name.capitalized
        self.pictureURL = url
        self.id = UUID().uuidString
        self.price = price
        self.date = Date()
    }

    var valueDico: [String : String] {
        return ["name" : self.name,
                "pictureURL" : self.pictureURL.absoluteString,
                "price" : self.price,
                "date"  : String(self.date.timeIntervalSince1970)
        ]
    }

    init?(data: DataSnapshot) {
        guard
            let value = data.value as? [String : String ],
            let name = value["name"],
            let price = value["price"],
            let pictureURL = value["pictureURL"],
            let date = value["date"],
            let removePercent = pictureURL.removingPercentEncoding,
            let url = URL(string: removePercent),
            let dateInt = TimeInterval(date) else { return nil }
        
        self.pictureURL = url
        self.name = name
        self.price = price
        self.id =  data.key
        self.date = Date(timeIntervalSince1970: dateInt)
    }
}

extension Food: Equatable {
    static func == (lhs: Food, rhs: Food) -> Bool {
        return lhs.id == rhs.id
    }
}
