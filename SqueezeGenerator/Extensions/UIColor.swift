//
//  UIColor.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 26.07.2025.
//

import UIKit

extension String {
    enum HexColor: String {
        case purpure = "23164E"
        case darkPurpure = "2C194F"
        case red = "CD4652"
        case lightRed = "D4326E"
        case pink = "702B78"
        case yellow = "FD9D3C"
    }
}

extension UIColor {
    static var random: UIColor {
        let results: [UIColor] = [.red, .yellow, .green, .blue]
        return results.randomElement()!
    }

    convenience init?(hexColor: String.HexColor) {
        self.init(hex: hexColor.rawValue)
    }

    convenience init?(hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            self.init(named: "CategoryColor")
            return
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
