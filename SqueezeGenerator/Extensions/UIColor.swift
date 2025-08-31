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
        case lightBlue = "00a6fb"
        case purpureLight = "7209b7"
        case puroure2Light = "BE7FF5"
        case lightPink = "FF7BEC"
        case yellow = "FD9D3C"
        case lightYellow = "f0f600"
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

    var isLight: Bool {
        let (r, g, b) = self.rgbInSRGB()
        let brightness = (r * 299 + g * 587 + b * 114) / 1000
        return brightness >= 0.4
    }

    // MARK: - Helpers
    private func rgbInSRGB() -> (CGFloat, CGFloat, CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) { return (r, g, b) }

        guard let srgb = cgColor.converted(
            to: CGColorSpace(name: CGColorSpace.sRGB)!,
            intent: .relativeColorimetric,
            options: nil),
              let comps = srgb.components
        else { return (0, 0, 0) }

        if comps.count == 2 {
            return (comps[0], comps[0], comps[0])
        } else {
            return (comps[0], comps[1], comps[2])
        }
    }
}


extension UIColor {
    func lighter(componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: componentDelta)
    }
    
    func darker(componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: -1*componentDelta)
    }
    
    private func makeColor(componentDelta: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0
        
        
        getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        )
        
        
        return UIColor(
            red: add(componentDelta, toComponent: red),
            green: add(componentDelta, toComponent: green),
            blue: add(componentDelta, toComponent: blue),
            alpha: alpha
        )
    }
    
    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
        return max(0, min(1, toComponent + value))
    }
}
