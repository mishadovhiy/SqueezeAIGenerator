//
//  Font_Configuration.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 10.08.2025.
//

import SwiftUI

extension Configuration.UI {
    enum FontType: CGFloat {
        case text = 13
        case section = 18
        case title = 24
        case description = 11
        case small = 9
        case extraLarge = 80

        var fontWeight: Font.Weight {
            switch self {
            case .small: .light
            case .section, .title: .bold
            default: .regular
            }
        }

        var font: Font {
            .system(size: rawValue, weight: fontWeight)
        }

        var opacity: CGFloat {
            switch self {
            case .small, .description: .Opacity.descriptionLight.rawValue
            default: 1
            }
        }
    }
}
