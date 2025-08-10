//
//  SpacingsConfiguration.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 10.08.2025.
//

import Foundation

extension Configuration.UI {
    enum Padding: CGFloat {
        case content = 20
        case smallButtonSize = 32
        case buttonHeight = 50

        enum CornerRadius: CGFloat {
            case large = 16
            case medium = 12
            case smallest = 6
            case small = 8

            static var button: Self = .smallest
        }
    }
}
