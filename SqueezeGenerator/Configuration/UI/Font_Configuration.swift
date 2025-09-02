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
        case largeTitle = 32
        case largeTitleBold = 32.01


        case description = 11
        case small = 9
        case extraLarge = 80

        var fontWeight: Font.Weight {
            switch self {
            case .small: .light
            case .section, .title, .largeTitleBold: .bold
            default: .regular
            }
        }

        var font: Font {
            font(weight: fontWeight)
        }
        
        func font(weight: Font.Weight) -> Font {
            .system(size: rawValue, weight: weight)
        }

        var opacity: CGFloat {
            switch self {
            case .small, .description: .Opacity.descriptionLight.rawValue
            default: 1
            }
        }
    }
}
