//
//  UIColor.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 26.07.2025.
//

import UIKit

extension UIColor {
    static var random: UIColor {
        let results: [UIColor] = [.red, .yellow, .green, .blue]
        return results.randomElement()!
    }
}
