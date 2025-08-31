//
//  Date.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 31.08.2025.
//

import Foundation

extension Date {
    var stringDate: String {
        stringDate(needTime: true)
    }

    func stringDate(needTime: Bool = false) -> String {
        self.formatted(date: .abbreviated, time: needTime ? .shortened : .omitted)
    }
}
